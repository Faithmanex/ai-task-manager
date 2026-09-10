import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/ai/gateway.dart';
import '../services/priority/priority_core.dart';

/// Central app state: tasks, AI gateway wiring, priorities.
class TaskController extends ChangeNotifier {
  TaskController({this.gateway})
    : tasks = [
        Task(
          id: 't1',
          title: 'Email Dana the revised deck',
          notes: 'Attach Q3 numbers',
          dueDate: DateTime.now().add(const Duration(hours: 20)),
          priority: Priority.high,
          createdAt: DateTime.now(),
        ),
        Task(
          id: 't2',
          title: 'Book dentist appointment',
          dueDate: DateTime.now().add(const Duration(days: 3)),
          priority: Priority.low,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Task(
          id: 't3',
          title: 'Plan team offsite agenda',
          subtasks: [
            Subtask(id: 's1', title: 'Collect topics'),
            Subtask(id: 's2', title: 'Draft schedule'),
          ],
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

  final AiGateway? gateway;
  final List<Task> tasks;

  bool get hasGateway => gateway != null;

  List<Task> get openTasks =>
      tasks.where((t) => !t.completed).toList()
        ..sort((a, b) => score(b).score.compareTo(score(a).score));

  List<Task> get completedTasks => tasks.where((t) => t.completed).toList();

  /// Hybrid priority: C++ core (or Dart fallback) score.
  ScoreResult score(Task task) => PriorityCore.instance.score(task);

  void addTask(Task task) {
    tasks.add(task);
    notifyListeners();
  }

  void addFromDraft(TaskDraft draft) {
    addTask(
      Task(
        id: _id(),
        title: draft.title,
        notes: draft.notes,
        dueDate: draft.dueDate,
        priority: draft.priority,
        tags: draft.tags,
        subtasks: draft.subtasks,
        createdAt: DateTime.now(),
      ),
    );
  }

  void toggleComplete(Task task) {
    task.completed = !task.completed;
    task.completedAt = task.completed ? DateTime.now() : null;
    notifyListeners();
  }

  void toggleSubtask(Task task, Subtask subtask) {
    subtask.completed = !subtask.completed;
    notifyListeners();
  }

  void removeTask(Task task) {
    tasks.remove(task);
    notifyListeners();
  }

  /// Natural language capture — returns null when no gateway is configured.
  Future<TaskDraft?> parseNaturalLanguage(String input) async {
    if (gateway == null) return null;
    return gateway!.parseTask(input);
  }

  String _id() => 't_${math.Random().nextInt(1 << 32).toRadixString(36)}';
}
