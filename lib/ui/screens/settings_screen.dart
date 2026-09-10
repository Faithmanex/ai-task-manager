import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// Settings: AI provider config, C++ core status.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, this.onDeleteAll});

  final VoidCallback? onDeleteAll;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kVoid,
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 20, color: kPaper),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'AI Gateway',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: kBone,
            ),
          ),
          const SizedBox(height: 12),
          _field('Base URL', 'https://api.openai.com/v1'),
          _field('API Key', 'sk-…'),
          _field('Chat model', 'gpt-4o-mini'),
          const SizedBox(height: 8),
          Text(
            'Keys are stored locally on this device only — never uploaded.',
            style: const TextStyle(fontSize: 13, color: kAsh),
          ),
          const SizedBox(height: 32),
          const Text(
            'Priority Engine',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: kBone,
            ),
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (context) => _statusTile(
              'C++ priority core',
              kIsWeb
                  ? 'Dart fallback active (web)'
                  : 'Native core or Dart fallback',
              !kIsWeb,
            ),
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: onDeleteAll,
            style: TextButton.styleFrom(foregroundColor: kCoralRed),
            child: const Text('Delete all data'),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, String hint) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      decoration: InputDecoration(labelText: label, hintText: hint),
    ),
  );

  Widget _statusTile(String title, String subtitle, bool ok) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: kCarbon,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: kGraphite),
    ),
    child: Row(
      children: [
        Icon(
          ok ? Icons.check_circle : Icons.info_outline,
          size: 18,
          color: ok ? kPulseGreen : kSignalTeal,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 15, color: kBone)),
            Text(subtitle, style: const TextStyle(fontSize: 13, color: kFog)),
          ],
        ),
      ],
    ),
  );
}
