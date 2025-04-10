import 'package:flutter/material.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final TextEditingController _controller = TextEditingController();

  void _saveTask() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      Navigator.pop(context, text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a task"),
        backgroundColor: Colors.deepPurple,
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isPortrait = orientation == Orientation.portrait;

          final textField = Expanded(
            flex: 3,
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "Enter the task...",
                border: OutlineInputBorder(),
              ),
              style: TextStyle(fontSize: isWide ? 20 : 16),
            ),
          );

          final saveButton = Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _saveTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                "Save",
                style: TextStyle(fontSize: isWide ? 20 : 18, color: Colors.white),
              ),
            ),
          );

          return Padding(
            padding: const EdgeInsets.all(24),
            child: isPortrait
                ? Column(
                    children: [
                      textField,
                      const SizedBox(height: 20),
                      saveButton,
                    ],
                  )
                : Row(
                    children: [
                      textField,
                      const SizedBox(width: 20),
                      saveButton,
                    ],
                  ),
          );
        },
      ),
    );
  }
}
