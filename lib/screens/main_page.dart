import 'package:flutter/material.dart';
import 'create_task.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<String> _tasks = [];

  void _navigateToCreateTask() async {
    final newTask = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTaskPage()),
    );

    if (newTask != null && newTask is String && newTask.trim().isNotEmpty) {
      setState(() {
        _tasks.add(newTask.trim());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            Widget content;
            if (constraints.maxWidth < 600) {
              content = buildMainContent(size, orientation, fontSize: 18);
            } else if (constraints.maxWidth < 1000) {
              content = buildMainContent(size, orientation, fontSize: 22);
            } else {
              content = Center(
                child: SizedBox(
                  width: 700,
                  child: buildMainContent(size, orientation, fontSize: 26),
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

  Widget buildMainContent(Size size, Orientation orientation, {required double fontSize}) {
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
        ElevatedButton(
          onPressed: _navigateToCreateTask,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            "Add task",
            style: TextStyle(fontSize: fontSize, color: Colors.white),
          ),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: _tasks.isEmpty
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.inbox, size: 64, color: Colors.deepPurple),
              SizedBox(height: 12),
              Text(
                "there are no tasks.",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            ],
          )
              : ListView.builder(
            itemCount: _tasks.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                    const Icon(Icons.check_circle_outline, color: Colors.deepPurple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _tasks[index],
                        style: TextStyle(fontSize: fontSize - 2),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}