import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';

class SyncBanner extends StatelessWidget {
  const SyncBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    if (!auth.shouldShowSyncButton) return const SizedBox.shrink();

    return Container(
      color: Colors.orange,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.sync, color: Colors.white),
          const SizedBox(width: 8),
          const Text('You have offline changes to sync',
              style: TextStyle(color: Colors.white)),
          const Spacer(),
          TextButton(
            onPressed: () async {
              try {
                await auth.syncData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Changes synced successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sync failed: ${e.toString()}')),
                );
              }
            },
            child: const Text('SYNC NOW',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}