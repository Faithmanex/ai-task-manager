import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_task_manager/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('home renders Today list and capture bar', (tester) async {
    await tester.pumpWidget(const AiTaskManagerApp());
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Email Dana the revised deck'), findsOneWidget);
    expect(find.text('Book dentist appointment'), findsOneWidget);
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

    final checkboxes = find.byType(GestureDetector);
    await tester.tap(checkboxes.first);
    await tester.pumpAndSettle();

    expect(find.textContaining('1 of'), findsOneWidget);
  });
}
