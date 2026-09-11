import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_task_manager/models/task.dart';
import 'package:ai_task_manager/services/ai/ai_settings_store.dart';
import 'package:ai_task_manager/services/ai/gateway.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AiSettingsStore', () {
    test('save and load config', () async {
      final store = AiSettingsStore();
      expect(await store.load(), isNull);

      final rawInitial = await store.loadRaw();
      expect(rawInitial['baseUrl'], '');
      expect(rawInitial['apiKey'], '');
      expect(rawInitial['model'], '');

      final config = AiConfig(
        baseUrl: 'https://api.openai.com/v1',
        apiKey: 'sk-testkey123',
        chatModel: 'gpt-4o',
      );

      await store.save(config);

      final loaded = await store.load();
      expect(loaded, isNotNull);
      expect(loaded!.baseUrl, 'https://api.openai.com/v1');
      expect(loaded.apiKey, 'sk-testkey123');
      expect(loaded.chatModel, 'gpt-4o');

      final raw = await store.loadRaw();
      expect(raw['baseUrl'], 'https://api.openai.com/v1');
      expect(raw['apiKey'], 'sk-testkey123');
      expect(raw['model'], 'gpt-4o');
    });
  });
  group('Task JSON round-trip', () {
    test('serializes and restores all fields', () {
      final task = Task(
        id: 't1',
        title: 'Email Dana the revised deck',
        notes: 'Attach Q3 numbers',
        dueDate: DateTime(2026, 9, 11, 17, 0),
        priority: Priority.high,
        completed: true,
        completedAt: DateTime(2026, 9, 10, 9, 30),
        subtasks: [
          Subtask(id: 's1', title: 'Collect topics', completed: true),
          Subtask(id: 's2', title: 'Draft schedule'),
        ],
        tags: ['work', 'urgent'],
        aiSuggested: true,
        createdAt: DateTime(2026, 9, 1),
      );

      final restored = Task.fromJson(task.toJson());

      expect(restored.id, task.id);
      expect(restored.title, task.title);
      expect(restored.notes, task.notes);
      expect(restored.dueDate, task.dueDate);
      expect(restored.priority, Priority.high);
      expect(restored.completed, isTrue);
      expect(restored.completedAt, task.completedAt);
      expect(restored.subtasks.length, 2);
      expect(restored.subtasks[0].title, 'Collect topics');
      expect(restored.subtasks[0].completed, isTrue);
      expect(restored.subtasks[1].completed, isFalse);
      expect(restored.tags, ['work', 'urgent']);
      expect(restored.aiSuggested, isTrue);
      expect(restored.createdAt, task.createdAt);
    });

    test('handles missing/optional fields gracefully', () {
      final restored = Task.fromJson({'id': 'x', 'title': 'Bare task'});

      expect(restored.title, 'Bare task');
      expect(restored.notes, '');
      expect(restored.dueDate, isNull);
      expect(restored.priority, Priority.medium);
      expect(restored.subtasks, isEmpty);
      expect(restored.completed, isFalse);
    });

    test('unknown priority falls back to medium', () {
      final restored = Task.fromJson({
        'id': 'x',
        'title': 't',
        'priority': 'ultra',
      });
      expect(restored.priority, Priority.medium);
    });
  });
}
