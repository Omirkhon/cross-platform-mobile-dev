import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class ProfilePage extends StatelessWidget {
  final AuthService auth;

  const ProfilePage({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser;
    final isGuest = auth.isGuest;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 40),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.deepPurple,
            child: Icon(
              isGuest ? Icons.person_outline : Icons.person,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              isGuest ? 'guest.title'.tr() : user?.email ?? '',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 40),
          if (!isGuest) ...[
            ListTile(
              leading: const Icon(Icons.email),
              title: Text('profile.email'.tr()),
              subtitle: Text(user?.email ?? ''),
            ),
            const Divider(),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await auth.signOut();
// Navigate back to auth page
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/auth',
                      (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('logout.button'.tr()),
            ),
          ),
        ],
      ),
    );
  }
}
