import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/task.dart';

/// Local-first persistence: tasks serialized as JSON in SharedPreferences.
/// Works on web (localStorage), desktop, and mobile.
class TaskStore {
  static const _key = 'ai_task_manager.tasks.v1';

  Future<List<Task>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(tasks.map((t) => t.toJson()).toList()),
    );
  }
}
