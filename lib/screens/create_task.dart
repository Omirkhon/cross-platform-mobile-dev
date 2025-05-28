import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CreateTaskPage extends StatefulWidget {
  final String? initialText;
  final DateTime? initialTime;
  final String? initialCategory;
  final String? initialId;

  const CreateTaskPage({
    super.key,
    this.initialText,
    this.initialTime,
    this.initialCategory,
    this.initialId,
  });

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final TextEditingController _controller = TextEditingController();
  TimeOfDay? _selectedTime;
  final List<String> _categories = [
    'Work',
    'Personal',
    'Shopping',
    'Health',
    'Learning',
    'Social',
    'Hobby',
    'Goals',
  ];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null) {
      _controller.text = widget.initialText!;
    }
    if (widget.initialTime != null) {
      _selectedTime = TimeOfDay.fromDateTime(widget.initialTime!);
    }
    _selectedCategory = widget.initialCategory;
  }

  void _saveTask() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      final taskData = {
        'text': text,
        'isDone': false,
        'category': _selectedCategory,
      };

      if (_selectedTime != null) {
        final now = DateTime.now();
        taskData['time'] = DateTime(
          now.year,
          now.month,
          now.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        ).millisecondsSinceEpoch;
      }
      if (widget.initialId != null) {
        taskData['id'] = widget.initialId;
      }
      Navigator.pop(context, taskData);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('createTask'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTask,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'taskName'.tr(),
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: Text('selectCategory'.tr()),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(
                _selectedTime == null
                    ? 'selectTime'.tr()
                    : 'selectedTime'.tr(args: [_selectedTime!.format(context)]),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _pickTime,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}