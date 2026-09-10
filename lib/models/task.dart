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

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'notes': notes,
    'dueDate': dueDate?.toIso8601String(),
    'priority': priority.name,
    'completed': completed,
    'completedAt': completedAt?.toIso8601String(),
    'subtasks': subtasks.map((s) => s.toJson()).toList(),
    'tags': tags,
    'aiSuggested': aiSuggested,
    'createdAt': createdAt?.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    title: json['title'] as String,
    notes: json['notes'] as String? ?? '',
    dueDate: DateTime.tryParse(json['dueDate'] as String? ?? ''),
    priority: Priority.values.firstWhere(
      (p) => p.name == json['priority'],
      orElse: () => Priority.medium,
    ),
    completed: json['completed'] as bool? ?? false,
    completedAt: DateTime.tryParse(json['completedAt'] as String? ?? ''),
    subtasks: (json['subtasks'] as List? ?? const [])
        .map((s) => Subtask.fromJson(s as Map<String, dynamic>))
        .toList(),
    tags: (json['tags'] as List? ?? const []).map((t) => t.toString()).toList(),
    aiSuggested: json['aiSuggested'] as bool? ?? false,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
  );
}

class Subtask {
  Subtask({required this.id, required this.title, this.completed = false});

  final String id;
  String title;
  bool completed;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'completed': completed,
  };

  factory Subtask.fromJson(Map<String, dynamic> json) => Subtask(
    id: json['id'] as String,
    title: json['title'] as String,
    completed: json['completed'] as bool? ?? false,
  );
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
