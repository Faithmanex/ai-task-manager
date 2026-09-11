import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_task_manager/controllers/task_controller.dart';
import 'package:ai_task_manager/main.dart';
import 'package:ai_task_manager/services/ai/ai_settings_store.dart';
import 'package:ai_task_manager/ui/screens/settings_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('home renders Today list and capture bar', (tester) async {
    await tester.pumpWidget(const AiTaskManagerApp());
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.textContaining('All clear'), findsOneWidget);
  });

  testWidgets('quick capture adds a plain task', (tester) async {
    await tester.pumpWidget(const AiTaskManagerApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Buy oat milk');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Buy oat milk'), findsOneWidget);
  });

  testWidgets('task can be completed', (tester) async {
    await tester.pumpWidget(const AiTaskManagerApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Buy oat milk');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('Buy oat milk'), findsOneWidget);

    final checkboxes = find.byType(GestureDetector);
    await tester.tap(checkboxes.first);
    await tester.pumpAndSettle();

    expect(find.textContaining('1 of'), findsOneWidget);
  });

  test('TaskController load handles empty state cleanly', () async {
    final controller = TaskController();
    expect(controller.isLoaded, isFalse);
    expect(controller.tasks, isEmpty);
    expect(controller.openTasks, isEmpty);
    expect(controller.completedTasks, isEmpty);

    await controller.load();

    expect(controller.isLoaded, isTrue);
    expect(controller.tasks, isEmpty);
    expect(controller.openTasks, isEmpty);
    expect(controller.completedTasks, isEmpty);
  });

  testWidgets('SettingsScreen loads and updates AiSettingsStore', (
    tester,
  ) async {
    final store = AiSettingsStore();
    await tester.pumpWidget(MaterialApp(home: SettingsScreen(store: store)));
    await tester.pumpAndSettle();

    expect(find.text('AI Gateway'), findsOneWidget);
    expect(find.text('Base URL'), findsOneWidget);

    final textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(3));

    await tester.enterText(textFields.at(0), 'https://api.custom.com/v1');
    await tester.enterText(textFields.at(1), 'sk-secret123');
    await tester.enterText(textFields.at(2), 'gpt-4o');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Settings'));
    await tester.pumpAndSettle();

    final config = await store.load();
    expect(config, isNotNull);
    expect(config!.baseUrl, 'https://api.custom.com/v1');
    expect(config.apiKey, 'sk-secret123');
    expect(config.chatModel, 'gpt-4o');
  });
}
