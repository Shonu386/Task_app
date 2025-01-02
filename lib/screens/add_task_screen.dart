import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:task_app/main.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class AddTaskScreen extends StatefulWidget {
  final Task? task; // Add a task parameter for editing

  const AddTaskScreen({super.key, this.task}); // Accept task for editing

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _reminderTime;
  String _repeatFrequency = 'None'; // Default value for repeat frequency

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _reminderTime = widget.task!.reminderTime;
      _repeatFrequency =
          widget.task!.repeatFrequency; // Pre-set repeat frequency when editing
    }
    tz.initializeTimeZones();
  }

  void _scheduleNotification(Task task) async {
    final scheduledDate = tz.TZDateTime.from(_reminderTime!, tz.local);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      task.id.hashCode,
      task.title,
      task.description,
      details,
      payload:
          scheduledDate.toString(), // Optional: Pass data with the notification
    );
  }

  void _saveTask() {
    if (_titleController.text.isEmpty || _reminderTime == null) {
      return;
    }

    final updatedTask = Task(
      id: widget.task?.id ??
          DateTime.now().toString(), // Use existing id if editing
      title: _titleController.text,
      description: _descriptionController.text,
      reminderTime: _reminderTime!,
      repeatFrequency: _repeatFrequency, // Save the selected repeat frequency
    );

    if (widget.task == null) {
      // If no task is passed (i.e., new task), add it
      Provider.of<TaskProvider>(context, listen: false).addTask(updatedTask);
      _scheduleNotification(updatedTask);
    } else {
      // If editing, update the task
      Provider.of<TaskProvider>(context, listen: false).editTask(updatedTask);
      _scheduleNotification(updatedTask);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.task == null ? 'Add Task' : 'Edit Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() {
                      _reminderTime = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
              child: const Text('Pick Reminder Time'),
            ),
            const SizedBox(height: 16),
            // Repeat Frequency Dropdown
            DropdownButton<String>(
              value: _repeatFrequency,
              onChanged: (value) {
                setState(() {
                  _repeatFrequency = value!;
                });
              },
              items: const [
                DropdownMenuItem(value: 'None', child: Text('None')),
                DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveTask,
              child: Text(widget.task == null ? 'Save Task' : 'Update Task'),
            ),
          ],
        ),
      ),
    );
  }
}
