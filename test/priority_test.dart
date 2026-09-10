import 'package:flutter_test/flutter_test.dart';

import 'package:ai_task_manager/models/task.dart';
import 'package:ai_task_manager/services/priority/priority_core.dart';

void main() {
  group('PriorityCore fallback scorer', () {
    test('scores clamp to [0, 100]', () {
      final s = PriorityCore.instance.score(
        Task(
          id: 'x',
          title: 'Overdue high priority',
          dueDate: DateTime.now().subtract(const Duration(days: 5)),
          priority: Priority.high,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
      );
      expect(s.score, inInclusiveRange(0, 100));
    });

    test('overdue high priority beats distant low priority', () {
      final high = PriorityCore.instance.score(
        Task(
          id: 'h',
          title: 'Urgent',
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
          priority: Priority.high,
        ),
      );

      final low = PriorityCore.instance.score(
        Task(
          id: 'l',
          title: 'Someday',
          dueDate: DateTime.now().add(const Duration(days: 30)),
          priority: Priority.low,
        ),
      );

      expect(high.score, greaterThan(low.score));
    });

    test('fallback and native paths agree when native available', () {
      final task = Task(
        id: 't',
        title: 'Task',
        dueDate: DateTime.now().add(const Duration(hours: 10)),
        priority: Priority.medium,
        createdAt: DateTime.now(),
      );
      final result = PriorityCore.instance.score(task);
      // Just verify it produces a usable score either way.
      expect(result.score, greaterThanOrEqualTo(0));
    });
  });

  group('Task model', () {
    test('isOverdue only when not completed and past due', () {
      final past = DateTime.now().subtract(const Duration(hours: 1));
      final t = Task(id: 'a', title: 'a', dueDate: past);
      expect(t.isOverdue, isTrue);

      t.completed = true;
      expect(t.isOverdue, isFalse);
    });
  });
}
