import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../controllers/task_controller.dart';
import '../../core/theme.dart';
import '../../services/ai/ai_settings_store.dart';
import '../../services/ai/gateway.dart';
import '../../services/ai/providers/openai_provider.dart';

/// Settings: AI gateway config (with Save), C++ core status.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.controller, this.onDeleteAll});

  final TaskController? controller;
  final VoidCallback? onDeleteAll;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _store = AiSettingsStore();
  final _baseUrl = TextEditingController();
  final _apiKey = TextEditingController();
  final _model = TextEditingController();
  bool _loaded = false;
  bool _saving = false;
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await _store.loadRaw();
    if (!mounted) return;
    _baseUrl.text = raw['baseUrl'] ?? '';
    _apiKey.text = raw['apiKey'] ?? '';
    _model.text = raw['model'] ?? '';
    setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _baseUrl.dispose();
    _apiKey.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final baseUrl = _baseUrl.text.trim();
    final apiKey = _apiKey.text.trim();
    final model = _model.text.trim();

    if (baseUrl.isEmpty || model.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Base URL and model are required')),
      );
      return;
    }
    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API key is required to enable the AI')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      // Strip trailing slash so '/chat/completions' resolves cleanly.
      final normalized = baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl;
      await _store.save(
        AiConfig(
          baseUrl: normalized,
          apiKey: apiKey,
          chatModel: model,
          parseModel: model,
        ),
      );
      // Hot-swap the live gateway so Day Pilot works immediately.
      widget.controller?.setGateway(
        OpenAiProvider(
          config: AiConfig(
            baseUrl: normalized,
            apiKey: apiKey,
            chatModel: model,
            parseModel: model,
          ),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('AI settings saved')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
          _field(
            controller: _baseUrl,
            label: 'Base URL',
            hint: 'https://api.openai.com/v1',
          ),
          _field(
            controller: _apiKey,
            label: 'API Key',
            hint: 'sk-…',
            obscure: _obscureKey,
            toggleObscure: () => setState(() => _obscureKey = !_obscureKey),
          ),
          _field(controller: _model, label: 'Model', hint: 'gpt-4o-mini'),
          const SizedBox(height: 8),
          const Text(
            'Works with any OpenAI-compatible endpoint (OpenAI, Ollama, '
            'LM Studio, vLLM). Keys are stored locally on this device only.',
            style: TextStyle(fontSize: 13, color: kAsh),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: Text(_saving ? 'Saving…' : 'Save AI settings'),
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
          _statusTile(
            'C++ priority core',
            kIsWeb ? 'Dart fallback active (web)' : 'Native core or fallback',
            !kIsWeb,
          ),
          if (widget.controller != null) ...[
            const SizedBox(height: 12),
            _statusTile(
              'AI status',
              widget.controller!.hasGateway
                  ? 'Day Pilot ready'
                  : 'Not configured — save settings above',
              widget.controller!.hasGateway,
            ),
          ],
          const SizedBox(height: 32),
          if (widget.onDeleteAll != null)
            TextButton(
              onPressed: widget.onDeleteAll,
              style: TextButton.styleFrom(foregroundColor: kCoralRed),
              child: const Text('Delete all data'),
            ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool obscure = false,
    VoidCallback? toggleObscure,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      obscureText: obscure,
      enabled: _loaded,
      style: const TextStyle(fontSize: 14, color: kMist),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: toggleObscure != null
            ? IconButton(
                onPressed: toggleObscure,
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: kFog,
                ),
              )
            : null,
      ),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, color: kBone)),
              Text(subtitle, style: const TextStyle(fontSize: 13, color: kFog)),
            ],
          ),
        ),
      ],
    ),
  );
}
