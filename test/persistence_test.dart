import 'package:flutter_test/flutter_test.dart';

import 'package:ai_task_manager/models/task.dart';

void main() {
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
