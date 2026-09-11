import 'package:shared_preferences/shared_preferences.dart';

import 'gateway.dart';

class AiSettingsStore {
  static const _kBaseUrl = 'ai_base_url';
  static const _kApiKey = 'ai_api_key';
  static const _kChatModel = 'ai_chat_model';

  Future<AiConfig?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final baseUrl = (prefs.getString(_kBaseUrl) ?? '').trim();
    final apiKey = (prefs.getString(_kApiKey) ?? '').trim();
    final model = (prefs.getString(_kChatModel) ?? '').trim();
    if (baseUrl.isEmpty || apiKey.isEmpty || model.isEmpty) return null;
    return AiConfig(
      baseUrl: baseUrl,
      apiKey: apiKey,
      chatModel: model,
      parseModel: model,
    );
  }

  Future<void> save(AiConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kBaseUrl, config.baseUrl);
    await prefs.setString(_kApiKey, config.apiKey);
    await prefs.setString(_kChatModel, config.chatModel);
  }

  Future<Map<String, String>> loadRaw() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'baseUrl': prefs.getString(_kBaseUrl) ?? '',
      'apiKey': prefs.getString(_kApiKey) ?? '',
      'model': prefs.getString(_kChatModel) ?? '',
    };
  }
}
