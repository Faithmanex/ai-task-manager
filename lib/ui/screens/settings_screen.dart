import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme.dart';
import '../../services/ai/ai_settings_store.dart';
import '../../services/ai/gateway.dart';

/// Settings: AI provider config, C++ core status.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.onDeleteAll,
    this.store,
    this.onSettingsSaved,
  });

  final VoidCallback? onDeleteAll;
  final AiSettingsStore? store;
  final ValueChanged<AiConfig?>? onSettingsSaved;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final AiSettingsStore _store;
  final _baseUrlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _modelController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? AiSettingsStore();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final raw = await _store.loadRaw();
    if (mounted) {
      setState(() {
        _baseUrlController.text = raw['baseUrl'] ?? '';
        _apiKeyController.text = raw['apiKey'] ?? '';
        _modelController.text = raw['model'] ?? '';
        _loading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    final baseUrl = _baseUrlController.text.trim();
    final apiKey = _apiKeyController.text.trim();
    final model = _modelController.text.trim();

    if (baseUrl.isNotEmpty && apiKey.isNotEmpty && model.isNotEmpty) {
      final config = AiConfig(
        baseUrl: baseUrl,
        apiKey: apiKey,
        chatModel: model,
        parseModel: model,
      );
      await _store.save(config);
      widget.onSettingsSaved?.call(config);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('ai_base_url');
      await prefs.remove('ai_api_key');
      await prefs.remove('ai_chat_model');
      widget.onSettingsSaved?.call(null);
    }
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

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
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kAcidLime))
          : ListView(
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
                _field(
                  'Base URL',
                  'https://api.openai.com/v1',
                  _baseUrlController,
                ),
                _field('API Key', 'sk-…', _apiKeyController, obscureText: true),
                _field('Chat model', 'gpt-4o-mini', _modelController),
                const SizedBox(height: 8),
                const Text(
                  'Keys are stored locally on this device only — never uploaded.',
                  style: TextStyle(fontSize: 13, color: kAsh),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _saveSettings();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Settings saved')),
                        );
                      }
                    },
                    child: const Text('Save Settings'),
                  ),
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
                  onPressed: widget.onDeleteAll,
                  style: TextButton.styleFrom(foregroundColor: kCoralRed),
                  child: const Text('Delete all data'),
                ),
              ],
            ),
    );
  }

  Widget _field(
    String label,
    String hint,
    TextEditingController controller, {
    bool obscureText = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(labelText: label, hintText: hint),
      onChanged: (_) => _saveSettings(),
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
