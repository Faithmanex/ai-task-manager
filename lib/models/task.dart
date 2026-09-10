/// Task priority, ordered low → high.
enum Priority { low, medium, high }

class Task {
  Task({
    required this.id,
    required this.title,
    this.notes = '',
    this.dueDate,
    this.priority = Priority.medium,
    this.completed = false,
    this.completedAt,
    this.subtasks = const [],
    this.tags = const [],
    this.aiSuggested = false,
    this.createdAt,
  });

  final String id;
  String title;
  String notes;
  DateTime? dueDate;
  Priority priority;
  bool completed;
  DateTime? completedAt;
  List<Subtask> subtasks;
  List<String> tags;
  bool aiSuggested;
  DateTime? createdAt;

  bool get isOverdue {
    final due = dueDate;
    return !completed && due != null && due.isBefore(DateTime.now());
  }
}

class Subtask {
  Subtask({required this.id, required this.title, this.completed = false});

  final String id;
  String title;
  bool completed;
}

/// Draft returned by the AI gateway from natural language input.
class TaskDraft {
  TaskDraft({
    required this.title,
    this.notes = '',
    this.dueDate,
    this.priority = Priority.medium,
    this.tags = const [],
    this.subtasks = const [],
  });

  final String title;
  final String notes;
  final DateTime? dueDate;
  final Priority priority;
  final List<String> tags;
  final List<Subtask> subtasks;
}

class SubtaskDraft {
  SubtaskDraft({required this.title, this.order = 0});
  final String title;
  int order;
}

class ChatMessage {
  ChatMessage({required this.role, required this.text, this.timestamp});

  final ChatRole role;
  String text;
  DateTime? timestamp;
}

enum ChatRole { user, assistant }
