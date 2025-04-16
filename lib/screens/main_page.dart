import 'package:flutter/material.dart';
import 'create_task.dart';
import 'dart:async';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class Task{
  final String text;
  bool isDone;
  final DateTime? time;
  final String? category;

  Task({required this.text, this.isDone=false , this.time, this.category});
}

class _MainPageState extends State<MainPage> {
  final List<Task> _tasks = [];
  late Timer _timer;

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
  void initState(){
    super.initState();
    _timer=Timer.periodic(const Duration(seconds: 30), _checkTasks);
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
      final taskText = newTask['task'];
      final taskTime = newTask['time'];
      final taskCategory = newTask['category'];
      setState(() {
        _tasks.add(Task(text: taskText , time: taskTime, category: taskCategory, ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      backgroundColor: Colors.grey[100],
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
              final task = _tasks[index];
              final taskTime = task.time;
              final isTimePassed = taskTime != null && taskTime.isBefore(DateTime.now());
              return GestureDetector(
                onTap:() {
                  setState(() {
                    task.isDone = !task.isDone;
                  });
                },
                child: Container(
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
                                fontSize: fontSize -2,
                                decoration: task.isDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: task.isDone ? Colors.grey : Colors.black87,
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
                          style: TextStyle(fontSize: 16, color: isTimePassed ? Colors.red : Colors.grey,),
                        )
                    ],
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