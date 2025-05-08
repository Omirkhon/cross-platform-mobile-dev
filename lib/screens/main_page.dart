import 'package:flutter/material.dart';
import 'create_task.dart';
import 'dart:async';
import 'auth_service.dart';  // Make sure to import the AuthService

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class Task {
  String text;
  bool isDone;
  DateTime? time;
  String? category;

  Task({
    required this.text,
    this.isDone = false,
    this.time,
    this.category,
  });
}

class _MainPageState extends State<MainPage> {
  final List<Task> _tasks = [];
  late Timer _timer;
  final AuthService _auth = AuthService();  // Initialize AuthService

  final Map<String, Color> _categoryColors = {
    "Work": Colors.blue,
    "Personal": Colors.orange,
    "Shopping": Colors.green,
    "Health": Colors.red,
    "Learning": Colors.purple,
    "Social": Colors.teal,
    "Hobby": Colors.brown,
    "Goals": Colors.pink,
  };

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), _checkTasks);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _checkTasks(Timer timer) {
    setState(() {
      for (var task in _tasks) {
        if (task.time != null && task.time!.isBefore(DateTime.now())) {
          task.isDone = true;
        }
      }
    });
  }

  void _navigateToCreateTask() async {
    final newTask = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTaskPage()),
    );

    if (newTask != null && newTask is Map) {
      final taskText = newTask['task'] as String?;
      final taskTime = newTask['time'] as DateTime?;
      final taskCategory = newTask['category'] as String?;

      if (taskText != null) {
        setState(() {
          _tasks.add(Task(
            text: taskText,
            time: taskTime,
            category: taskCategory,
          ));
        });
      }
    }
  }

  void _editTask(int index) async {
    final editedTask = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTaskPage(
          initialText: _tasks[index].text,
          initialTime: _tasks[index].time,
          initialCategory: _tasks[index].category,
        ),
      ),
    );

    if (editedTask != null && editedTask is Map) {
      final taskText = editedTask['task'] as String?;
      final taskTime = editedTask['time'] as DateTime?;
      final taskCategory = editedTask['category'] as String?;

      if (taskText != null) {
        setState(() {
          _tasks[index].text = taskText;
          _tasks[index].time = taskTime;
          _tasks[index].category = taskCategory;
        });
      }
    }
  }

  void _deleteTask(int index) {
    final deletedTask = _tasks[index];
    setState(() {
      _tasks.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "${deletedTask.text}" deleted'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isGuest = _auth.currentUser == null;  // Check if user is guest

    // Guest mode banner
    if (isGuest) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.amber,
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.black),
                const SizedBox(width: 8),
                const Text(
                  'Guest Mode - Some features are disabled',
                  style: TextStyle(color: Colors.black),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text(
                    'Sign In',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildMainContent(size, orientation, theme),
          ),
        ],
      );
    }

    // Regular logged-in view
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateTask,
        backgroundColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            Widget content;
            if (constraints.maxWidth < 600) {
              content = _buildMainContent(size, orientation, theme, fontSize: 18);
            } else if (constraints.maxWidth < 1000) {
              content = _buildMainContent(size, orientation, theme, fontSize: 22);
            } else {
              content = Center(
                child: SizedBox(
                  width: 700,
                  child: _buildMainContent(size, orientation, theme, fontSize: 26),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: content,
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(Size size, Orientation orientation, ThemeData theme, {double fontSize = 18}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: Text(
            "TO-DO LIST",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _tasks.isEmpty
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 64, color: Colors.deepPurple),
              const SizedBox(height: 12),
              Text(
                "There are no tasks.",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          )
              : ListView.builder(
            itemCount: _tasks.length,
            itemBuilder: (context, index) {
              final task = _tasks[index];
              final taskTime = task.time;
              final isTimePassed = taskTime != null && taskTime.isBefore(DateTime.now());

              return Dismissible(
                key: Key(task.text + index.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.redAccent,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _deleteTask(index),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      task.isDone = !task.isDone;
                    });
                  },
                  onLongPress: () => _editTask(index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          task.isDone
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: task.isDone ? Colors.green : Colors.deepPurple,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.text,
                                style: TextStyle(
                                  fontSize: fontSize - 2,
                                  decoration: task.isDone
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: task.isDone
                                      ? theme.disabledColor
                                      : theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              if (task.category != null)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _categoryColors[task.category] ?? Colors.grey,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    task.category!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                        if (task.time != null)
                          Text(
                            '${task.time!.hour.toString().padLeft(2, '0')}:${task.time!.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 16,
                              color: isTimePassed ? Colors.red : theme.hintColor,
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
