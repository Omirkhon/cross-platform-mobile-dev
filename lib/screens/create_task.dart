import 'package:flutter/material.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final TextEditingController _controller = TextEditingController();
  TimeOfDay? _selectedTime;
  final List<String> _categories = ["Work", "Personal", "Shopping", "Health", "Learning", "Social", "Hobby", "Goals"];
String? _selectedCategory;

  void _saveTask() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      final taskTime = _selectedTime != null
          ? DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            _selectedTime!.hour,
            _selectedTime!.minute,
          )
          : null;
      Navigator.pop(context, {'task': text , 'time': taskTime, 'category': _selectedCategory,});
    }
  }

  Future<void> _pickTime() async{
    final time = await showTimePicker(
      context: context, 
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Create a task"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      body: OrientationBuilder(
        builder: (context, orientation) {
          final isPortrait = orientation == Orientation.portrait;

          final textField = Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
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

          final timeButton = ElevatedButton(
            onPressed: _pickTime,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.deepPurple, width: 2),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              _selectedTime == null
                  ? 'Pick time'
                  : 'Time: ${_selectedTime!.format(context)}',
              style: TextStyle(fontSize: isWide ? 20 : 18, color: Colors.deepPurple),
              ),
            );

            final categoryDropdown = Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: const Text("Choose category"),
                items: _categories
                    .map((cat) => DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                ),
                style: const TextStyle(color: Colors.deepPurple, fontSize: 16),
                dropdownColor: Colors.white,
              ),
            );

          final saveButton = Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SizedBox(
              width: isPortrait ? double.infinity : 200,
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
            ),
          );

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    textField,
                    categoryDropdown,
                    timeButton,
                  ],
                ),
              ),
              saveButton,
            ],
          );
        },
      ),
    );
  }
}
