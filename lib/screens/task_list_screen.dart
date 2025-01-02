import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_app/main.dart';
import '../providers/task_provider.dart';
import '../widgets/task_item.dart';
import 'add_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String selectedCategory = 'All'; // Default category

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    // Filter tasks based on selected category
    final filteredTasks = selectedCategory == 'All'
        ? taskProvider.tasks
        : taskProvider.tasks
            .where((task) => task.category == selectedCategory)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
        actions: [
          Switch(
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (value) {
              // Toggle between light and dark mode
              themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          PopupMenuButton<String>(
            onSelected: (category) {
              setState(() {
                selectedCategory = category;
              });
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: 'All', child: Text('All')),
              PopupMenuItem(value: 'Daily', child: Text('Daily')),
              PopupMenuItem(value: 'Weekly', child: Text('Weekly')),
              PopupMenuItem(value: 'Monthly', child: Text('Monthly')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredTasks.length,
        itemBuilder: (ctx, index) {
          return TaskItem(
            task: filteredTasks[index],
            onDelete: () {
              taskProvider.deleteTask(filteredTasks[index].id);
            },
            onEdit: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => AddTaskScreen(
                  task: filteredTasks[index],
                ),
              ));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => const AddTaskScreen(),
          ));
        },
      ),
    );
  }
}
