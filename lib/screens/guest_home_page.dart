import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'auth_service.dart';
import 'create_task.dart';
import 'connectivity_service.dart';
import 'sync_banner.dart';

class GuestHomePage extends StatelessWidget {
  const GuestHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final isOffline = context.watch<ConnectivityService>().isOffline;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Chip(
              label: Text(
                'GUEST',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.orange,
              padding: EdgeInsets.symmetric(horizontal: 8),
            ),
            if (isOffline)
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(Icons.cloud_off, color: Colors.white),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/auth', (route) => false);
            },
            child: Text(
              'login.button'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateTask(context),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          if (auth.shouldShowSyncButton) const SyncBanner(),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: auth.tasksStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tasks = snapshot.data ?? [];

                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inbox, size: 64, color: Colors.deepPurple),
                        const SizedBox(height: 16),
                        Text('noTasks'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) => _buildSwipeableTaskItem(context, tasks[index], auth),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeableTaskItem(BuildContext context, Map<String, dynamic> task, AuthService auth) {
    return Dismissible(
      key: Key(task['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        auth.deleteTask(task['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('taskDeleted'.tr())),
        );
      },
      child: _buildTaskItem(context, task, auth),
    );
  }

  Widget _buildTaskItem(BuildContext context, Map<String, dynamic> task, AuthService auth) {
    final theme = Theme.of(context);
    final isDone = task['isDone'] ?? false;
    final time = task['time'] != null ? DateTime.fromMillisecondsSinceEpoch(task['time']) : null;
    final baseStyle = theme.textTheme.bodyLarge!;
    final textStyle = isDone
        ? baseStyle.copyWith(
      decoration: TextDecoration.lineThrough,
      color: baseStyle.color!.withOpacity(0.5),
    )
        : baseStyle;
    final cardColor = isDone ? theme.colorScheme.surfaceVariant : theme.cardColor;
    final elevation = isDone ? 0.0 : 2.0;

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: elevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Checkbox(
          value: isDone,
          onChanged: auth.isGuest
              ? (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('pleaseLogin'.tr())),
            );
          }
              : (v) => auth.updateTask(task['id'], {'isDone': v}),
          activeColor: Colors.deepPurple,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task['text'], style: textStyle),
            if (task['category'] != null) ...[
              const SizedBox(height: 4),
              Chip(
                label: Text(task['category']),
                backgroundColor: _getCategoryColor(task['category']),
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              ),
            ],
          ],
        ),
        trailing: time != null
            ? Text('${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}')
            : null,
        onTap: () => _editTask(context, task, auth),
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    const colors = {
      "Work": Colors.blue,
      "Personal": Colors.orange,
      "Shopping": Colors.green,
      "Health": Colors.red,
      "Learning": Colors.purple,
      "Social": Colors.teal,
      "Hobby": Colors.brown,
      "Goals": Colors.pink,
    };
    return colors[category] ?? Colors.grey;
  }

  void _navigateToCreateTask(BuildContext context) async {
    final newTask = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTaskPage()),
    );

    if (newTask != null && newTask is Map<String, dynamic>) {
      final auth = Provider.of<AuthService>(context, listen: false);
      await auth.addTask(newTask);
    }
  }

  void _editTask(BuildContext context, Map<String, dynamic> task, AuthService auth) async {
    final editedTask = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTaskPage(
          initialText: task['text'],
          initialTime: task['time'] != null
              ? DateTime.fromMillisecondsSinceEpoch(task['time'])
              : null,
          initialCategory: task['category'],
        ),
      ),
    );

    if (editedTask != null && editedTask is Map<String, dynamic>) {
      await auth.updateTask(task['id'], editedTask);
    }
  }
}