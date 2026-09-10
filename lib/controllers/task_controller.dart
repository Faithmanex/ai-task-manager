import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/ai/gateway.dart';
import '../services/database/task_store.dart';
import '../services/priority/priority_core.dart';

/// Central app state: tasks, persistence, AI gateway wiring, priorities.
class TaskController extends ChangeNotifier {
  TaskController({this.gateway, TaskStore? store})
    : _store = store ?? TaskStore(),
      tasks = [];

  final AiGateway? gateway;
  final TaskStore _store;
  final List<Task> tasks;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  /// Load persisted tasks once at startup. Call before first frame.
  Future<void> load() async {
    if (_loaded) return;
    final stored = await _store.load();
    if (stored.isEmpty) {
      tasks.addAll(_seedTasks());
    } else {
      tasks.addAll(stored);
    }
    _loaded = true;
    notifyListeners();
  }

  List<Task> _seedTasks() => [
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

  bool get hasGateway => gateway != null;

  List<Task> get openTasks =>
      tasks.where((t) => !t.completed).toList()
        ..sort((a, b) => score(b).score.compareTo(score(a).score));

  List<Task> get completedTasks => tasks.where((t) => t.completed).toList();

  /// Hybrid priority: C++ core (or Dart fallback) score.
  ScoreResult score(Task task) => PriorityCore.instance.score(task);

  void addTask(Task task) {
    tasks.add(task);
    _persist();
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
    _persist();
    notifyListeners();
  }

  void toggleSubtask(Task task, Subtask subtask) {
    subtask.completed = !subtask.completed;
    _persist();
    notifyListeners();
  }

  void removeTask(Task task) {
    tasks.remove(task);
    _persist();
    notifyListeners();
  }

  /// Clear everything (Settings → Delete all data).
  Future<void> deleteAll() async {
    tasks.clear();
    await _store.save(tasks);
    notifyListeners();
  }

  /// Natural language capture — returns null when no gateway is configured.
  Future<TaskDraft?> parseNaturalLanguage(String input) async {
    if (gateway == null) return null;
    return gateway!.parseTask(input);
  }

  void _persist() {
    _store.save(tasks); // fire-and-forget; store is resilient
  }

  String _id() => 't_${math.Random().nextInt(1 << 32).toRadixString(36)}';
}
