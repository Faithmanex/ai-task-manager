import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'ui/screens/home_screen.dart';

void main() {
  runApp(const AiTaskManagerApp());
}

class AiTaskManagerApp extends StatelessWidget {
  const AiTaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Task Manager',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const HomeScreen(),
    );
  }
}
