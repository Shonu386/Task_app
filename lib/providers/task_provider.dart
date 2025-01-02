import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => [..._tasks];

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void editTask(Task updatedTask) {
    final taskIndex = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (taskIndex >= 0) {
      _tasks[taskIndex] = updatedTask;
      notifyListeners();
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }

  void handleRepeatingTasks(Task task) {
    DateTime nextReminderTime = task.reminderTime;

    switch (task.repeatFrequency) {
      case 'Daily':
        nextReminderTime = nextReminderTime.add(const Duration(days: 1));
        break;
      case 'Weekly':
        nextReminderTime = nextReminderTime.add(const Duration(days: 7));
        break;
      case 'Monthly':
        nextReminderTime = DateTime(nextReminderTime.year,
            nextReminderTime.month + 1, nextReminderTime.day);
        break;
      case 'None':
      default:
        return;
    }

    // Create a new task for the next occurrence
    final repeatedTask = Task(
      id: DateTime.now().toString(), // New ID
      title: task.title,
      description: task.description,
      reminderTime: nextReminderTime,
      repeatFrequency: task.repeatFrequency,
    );

    addTask(repeatedTask); // Add the repeated task
  }
}
