class Task {
  final String id;
  final String title;
  final String description;
  final DateTime reminderTime;
  final String repeatFrequency; // "Daily", "Weekly", "Monthly"
  final String category; // New field for category

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.reminderTime,
    this.repeatFrequency = 'None',
    this.category = 'All', // Default category is 'All'
  });
}
