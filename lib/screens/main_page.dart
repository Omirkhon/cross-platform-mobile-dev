import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'auth_service.dart';
import 'create_task.dart';
import 'sync_banner.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String searchQuery = '';
  String? selectedCategory;
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return Scaffold(
      floatingActionButton: auth.isGuest
          ? FloatingActionButton(
              onPressed: () => _showGuestRestriction(context),
              backgroundColor: Colors.orange,
              child: const Icon(Icons.warning, color: Colors.white),
            )
          : FloatingActionButton(
              onPressed: () => _navigateToCreateTask(context),
              backgroundColor: Colors.deepPurple,
              child: const Icon(Icons.add, color: Colors.white),
            ),
      body: Column(
        children: [
          if (auth.shouldShowSyncButton) const SyncBanner(),
          if (auth.isGuest)
            _buildGuestRestriction(context)
          else
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'title'.tr(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value.toLowerCase();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'search'.tr(),
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedCategory,
                                hint: Text('filterCategory'.tr()),
                                items: [
                                  null,
                                  "Work",
                                  "Personal",
                                  "Shopping",
                                  "Health",
                                  "Learning",
                                  "Social",
                                  "Hobby",
                                  "Goals",
                                ]
                                    .map(
                                      (cat) => DropdownMenuItem<String>(
                                        value: cat,
                                        child: Text(cat ?? 'allCategories'.tr()),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedCategory = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (pickedDate != null) {
                                  setState(() {
                                    selectedDate = pickedDate;
                                  });
                                }
                              },
                              icon: const Icon(Icons.calendar_today),
                              label: Text(selectedDate == null
                                  ? 'filterDate'.tr()
                                  : DateFormat.yMMMd().format(selectedDate!)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.clear),
                              tooltip: 'clearFilters'.tr(),
                              onPressed: () {
                                setState(() {
                                  searchQuery = '';
                                  selectedCategory = null;
                                  selectedDate = null;
                                });
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: auth.tasksStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        var tasks = (snapshot.data ?? [])
                            .where((t) => t['deleted'] != true)
                            .toList();

                        // Фильтрация
                        tasks = tasks.where((task) {
                          final text = (task['text'] ?? '').toLowerCase();
                          final matchText = searchQuery.isEmpty || text.contains(searchQuery);
                          final matchCategory = selectedCategory == null ||
                              task['category'] == selectedCategory;
                          final taskTime = task['time'] != null
                              ? DateTime.fromMillisecondsSinceEpoch(task['time'])
                              : null;
                          final matchDate = selectedDate == null ||
                              (taskTime != null &&
                                  taskTime.year == selectedDate!.year &&
                                  taskTime.month == selectedDate!.month &&
                                  taskTime.day == selectedDate!.day);
                          return matchText && matchCategory && matchDate;
                        }).toList();

                        // Сортировка: незавершённые вверху
                        tasks.sort((a, b) {
                          final aDone = a['isDone'] ?? false;
                          final bDone = b['isDone'] ?? false;
                          return aDone == bDone ? 0 : (aDone ? 1 : -1);
                        });

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
                          itemBuilder: (context, index) =>
                              _buildSwipeableTaskItem(context, tasks[index], auth),
                        );
                      },
                    ),
                  ),
                ],
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
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('confirmDelete'.tr()),
            content: Text('deleteTaskConfirm'.tr(args: [task['text']])),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('cancel'.tr()),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('delete'.tr(), style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        auth.deleteTask(task['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('taskDeleted'.tr()),
            action: SnackBarAction(
              label: 'undo'.tr(),
              onPressed: () {
                // Реализовать Undo при необходимости
              },
            ),
          ),
        );
      },
      child: _buildTaskItem(context, task, auth),
    );
  }

  Widget _buildTaskItem(BuildContext context, Map<String, dynamic> task, AuthService auth) {
    final theme = Theme.of(context);
    final isDone = task['isDone'] ?? false;
    final time = task['time'] != null ? DateTime.fromMillisecondsSinceEpoch(task['time']) : null;
    final isTimePassed = time != null && time.isBefore(DateTime.now());
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
      elevation: elevation,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Checkbox(
          value: isDone,
          onChanged: (v) => auth.updateTask(task['id'], {'isDone': v}),
          activeColor: Colors.deepPurple,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task['text'],
              style: textStyle,
            ),
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
            ? Text(
                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                style: TextStyle(color: isTimePassed ? Colors.red : theme.hintColor),
              )
            : null,
        onTap: () => _editTask(context, task, auth),
      ),
    );
  }

  Widget _buildGuestRestriction(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning, size: 64, color: Colors.orange),
          const SizedBox(height: 20),
          Text('guest_restriction'.tr(),
              style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () =>
                Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false),
            child: Text('login.button'.tr()),
          ),
        ],
      ),
    );
  }

  void _showGuestRestriction(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('guest_restriction'.tr()),
        duration: const Duration(seconds: 2),
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
