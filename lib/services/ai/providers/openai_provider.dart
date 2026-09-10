/// OpenAI-compatible provider adapter (OpenAI, Ollama, LM Studio, vLLM …).
library;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../models/task.dart';
import '../gateway.dart';
import '../prompts.dart';

/// Implements [AiGateway] against any OpenAI-compatible REST endpoint.
class OpenAiProvider implements AiGateway {
  OpenAiProvider({required this.config, http.Client? client})
    : _client = client ?? http.Client();

  final AiConfig config;
  final http.Client _client;

  static const _timeout = Duration(seconds: 60);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${config.apiKey}',
  };

  Uri _uri(String path) => Uri.parse('${config.baseUrl}$path');

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> body, {
    String? model,
  }) async {
    final response = await _client
        .post(
          _uri(path),
          headers: _headers,
          body: jsonEncode({...body, 'model': model ?? config.chatModel}),
        )
        .timeout(_timeout);

    if (response.statusCode >= 400) {
      throw AiNetworkException('HTTP ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Single completion, JSON-mode, returns decoded JSON object.
  Future<Map<String, dynamic>> _jsonComplete(
    String prompt, {
    String? model,
  }) async {
    final data = await _postJson('/chat/completions', {
      'messages': [
        {'role': 'user', 'content': prompt},
      ],
      'response_format': {'type': 'json_object'},
      'temperature': 0.1,
    }, model: model ?? config.parseModel);

    final choices = data['choices'] as List?;
    final content =
        (choices?.first as Map<String, dynamic>?)?['content'] as String? ?? '';
    try {
      final decoded = jsonDecode(content);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const AiParseException('Model did not return a JSON object');
    } on FormatException {
      throw const AiParseException('Unparseable model output');
    }
  }

  Priority _resolvePriority(String? value) => switch (value) {
    'low' => Priority.low,
    'high' => Priority.high,
    _ => Priority.medium,
  };

  @override
  Future<TaskDraft> parseTask(String input) async {
    final json = await _jsonComplete(
      kParseTaskPrompt
          .replaceAll('{date}', _today())
          .replaceAll('{input}', input),
    );

    return TaskDraft(
      title: (json['title'] as String? ?? input).trim(),
      notes: json['notes'] as String? ?? '',
      dueDate: (json['dueDate'] as String?)?.isEmpty == true
          ? null
          : _tryParseDate(json['dueDate'] as String?),
      priority: _resolvePriority(json['priority'] as String?),
      tags: (json['tags'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
      subtasks: (json['subtasks'] as List? ?? const [])
          .map((e) => Subtask(id: _localId(), title: e.toString()))
          .toList(),
    );
  }

  @override
  Future<List<SubtaskDraft>> generateSubtasks(Task task) async {
    final json = await _jsonComplete(
      kGenerateSubtasksPrompt
          .replaceAll('{title}', task.title)
          .replaceAll('{notes}', task.notes)
          .replaceAll('{due}', task.dueDate?.toIso8601String() ?? 'none'),
    );

    return (json['subtasks'] as List? ?? const [])
        .map(
          (e) => Subtask(id: _localId(), title: (e as Map)['title'].toString()),
        )
        .map((s) => SubtaskDraft(title: s.title))
        .toList();
  }

  @override
  Future<PriorityRationale> explainPriority(Task task, TaskContext ctx) async {
    final json = await _jsonComplete(
      kExplainPriorityPrompt
          .replaceAll('{title}', task.title)
          .replaceAll('{due}', task.dueDate?.toIso8601String() ?? 'none')
          .replaceAll('{priority}', task.priority.name)
          .replaceAll('{open}', ctx.openTaskCount.toString())
          .replaceAll('{today}', ctx.todayTaskCount.toString()),
    );

    return PriorityRationale(
      taskId: task.id,
      rationale: json['rationale'] as String? ?? '',
    );
  }

  @override
  Stream<ChatChunk> chat(List<ChatMessage> history, TaskContext ctx) async* {
    final messages = [
      {
        'role': 'system',
        'content': kDayPilotSystemPrompt
            .replaceAll('{date}', _today())
            .replaceAll('{open}', ctx.openTaskCount.toString())
            .replaceAll('{today}', ctx.todayTaskCount.toString()),
      },
      ...history.map(
        (m) => {
          'role': m.role == ChatRole.user ? 'user' : 'assistant',
          'content': m.text,
        },
      ),
    ];

    final request = http.Request('POST', _uri('/chat/completions'))
      ..headers.addAll(_headers)
      ..body = jsonEncode({
        'model': config.chatModel,
        'messages': messages,
        'stream': true,
      });

    final response = await _client.send(request).timeout(_timeout);
    if (response.statusCode >= 400) {
      throw AiNetworkException('HTTP ${response.statusCode}');
    }

    final buffer = StringBuffer();
    await for (final line
        in response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())) {
      if (!line.startsWith('data: ')) continue;
      final payload = line.substring(6).trim();
      if (payload == '[DONE]') break;
      try {
        final delta = jsonDecode(payload)['choices'][0]['delta']['content'];
        if (delta is String && delta.isNotEmpty) {
          buffer.write(delta);
          yield ChatChunk(text: delta);
        }
      } on FormatException {
        // Ignore malformed keepalive lines.
      }
    }
    yield ChatChunk(text: '', done: true);
  }

  @override
  Future<DailyReview> dailyReview(DayLog log) async {
    final json = await _jsonComplete(
      kDailyReviewPrompt
          .replaceAll('{completed}', log.completedTitles.join('; '))
          .replaceAll('{open}', log.openTitles.join('; ')),
    );

    List<String> strings(Object? v) =>
        (v as List? ?? const []).map((e) => e.toString()).toList();

    return DailyReview(
      wins: strings(json['wins']),
      misses: strings(json['misses']),
      tomorrowTopThree: strings(json['tomorrowTopThree']),
    );
  }

  String _today() => DateTime.now().toIso8601String().substring(0, 10);

  static DateTime? _tryParseDate(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    return DateTime.tryParse(iso);
  }

  static String _localId() =>
      'ai_${DateTime.now().microsecondsSinceEpoch}_${_seq++}';
  static int _seq = 0;
}
