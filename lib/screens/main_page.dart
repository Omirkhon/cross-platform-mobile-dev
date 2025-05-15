import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'auth_service.dart';
import 'create_task.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateTask(context),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
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
                  Text(
                    'noTasks'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildTaskItem(context, task, auth);
            },
          );
        },
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, Map<String, dynamic> task, AuthService auth) {
    final theme = Theme.of(context);
    final isDone = task['isDone'] ?? false;
    final time = task['time'] != null ? DateTime.fromMillisecondsSinceEpoch(task['time']) : null;
    final isTimePassed = time != null && time.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Checkbox(
          value: isDone,
          onChanged: (value) => auth.updateTask(task['id'], {'isDone': value}),
          activeColor: Colors.deepPurple,
        ),
        title: Text(
          task['text'],
          style: TextStyle(
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone ? theme.disabledColor : theme.textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: task['category'] != null
            ? Chip(
          label: Text(task['category']),
          backgroundColor: _getCategoryColor(task['category']),
        )
            : null,
        trailing: time != null
            ? Text(
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
          style: TextStyle(
            color: isTimePassed ? Colors.red : theme.hintColor,
          ),
        )
            : null,
        onTap: () => _editTask(context, task, auth),
        onLongPress: () => _deleteTask(context, task['id'], auth),
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

  void _deleteTask(BuildContext context, String taskId, AuthService auth) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('confirmDelete'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('delete'.tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await auth.deleteTask(taskId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('taskDeleted'.tr())),
        );
      }
    }
  }
}