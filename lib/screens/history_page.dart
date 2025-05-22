import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'auth_service.dart';
import 'connectivity_service.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  DateTime parseDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
    return DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final isOffline = context.watch<ConnectivityService>().isOffline;

    return Scaffold(
      appBar: AppBar(
        title: Text('nav.history'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear Deleted Tasks',
            onPressed: () => _confirmClearHistory(context),
          ),
        ],
      ),
      body: isOffline
          ? _buildOfflineList()
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: auth.tasksStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tasks = (snapshot.data ?? [])
                  ..sort((a, b) => parseDate(b['createdAt']).compareTo(parseDate(a['createdAt'])));

                return _buildTaskList(context, tasks);
              },
            ),
    );
  }

  Widget _buildOfflineList() {
    final box = Hive.box('localStorage');
    final localTasks = List<Map<String, dynamic>>.from(box.get('tasks', defaultValue: []));

    localTasks.sort((a, b) {
      final aTime = a['createdAt'] ?? 0;
      final bTime = b['createdAt'] ?? 0;
      return bTime.compareTo(aTime);
    });

    return _buildTaskList(null, localTasks);
  }

  Widget _buildTaskList(BuildContext? context, List<Map<String, dynamic>> tasks) {
    if (tasks.isEmpty) {
      return Center(child: Text('history.empty'.tr()));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final isDone = task['isDone'] ?? false;
        final isDeleted = task['deleted'] == true;
        final time = task['time'] != null
            ? DateTime.fromMillisecondsSinceEpoch(task['time'])
            : null;
        final createdAt = task['createdAt'] is int
            ? DateTime.fromMillisecondsSinceEpoch(task['createdAt'])
            : (task['createdAt'] is Timestamp
                ? (task['createdAt'] as Timestamp).toDate()
                : DateTime.now());

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(
              task['text'] ?? '',
              style: isDeleted
                  ? const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.redAccent)
                  : null,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task['category'] != null)
                  Text('Category: ${task['category']}'),
                if (time != null)
                  Text('Time: ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'),
                Text('Created at: ${DateFormat('yyyy-MM-dd HH:mm').format(createdAt)}'),
                if (isDeleted)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Deleted',
                      style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
                    ),
                  ),
              ],
            ),
            trailing: Icon(
              isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isDone ? Colors.green : Colors.grey,
            ),
          ),
        );
      },
    );
  }

  void _confirmClearHistory(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('clear_history_title'.tr()),
        content: Text('clear_history_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('clear_history_cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('clear_history_confirm'.tr()),
          ),
        ],
      ), 
    );

    if (confirmed != true) return;

    final auth = Provider.of<AuthService>(context, listen: false);
    final tasks = await auth.tasksStream.first;

    for (final task in tasks.where((t) =>
        t['deleted'] == true || t['isDone'] == true)) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('tasks')
          .doc(task['id'])
          .delete();
    }

    final box = Hive.box('localStorage');
    final localTasks = List<Map<String, dynamic>>.from(box.get('tasks', defaultValue: []));
    final cleaned = localTasks.where((t) =>
        t['deleted'] != true && t['isDone'] != true).toList();
    await box.put('tasks', cleaned);
  }

}
