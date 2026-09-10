/// Stub adapters for Anthropic and Gemini — implement per PROMPT.md contract.
library;

import '../../../models/task.dart';
import '../gateway.dart';

/// Placeholder Claude adapter — same contract as OpenAiProvider.
class AnthropicProvider implements AiGateway {
  AnthropicProvider({required this.config});

  final AiConfig config;

  @override
  Future<TaskDraft> parseTask(String input) => throw UnimplementedError();

  @override
  Future<List<SubtaskDraft>> generateSubtasks(Task task) =>
      throw UnimplementedError();

  @override
  Future<PriorityRationale> explainPriority(Task task, TaskContext ctx) =>
      throw UnimplementedError();

  @override
  Stream<ChatChunk> chat(List<ChatMessage> history, TaskContext ctx) =>
      throw UnimplementedError();

  @override
  Future<DailyReview> dailyReview(DayLog log) => throw UnimplementedError();
}

/// Placeholder Gemini adapter — same contract as OpenAiProvider.
class GeminiProvider implements AiGateway {
  GeminiProvider({required this.config});

  final AiConfig config;

  @override
  Future<TaskDraft> parseTask(String input) => throw UnimplementedError();

  @override
  Future<List<SubtaskDraft>> generateSubtasks(Task task) =>
      throw UnimplementedError();

  @override
  Future<PriorityRationale> explainPriority(Task task, TaskContext ctx) =>
      throw UnimplementedError();

  @override
  Stream<ChatChunk> chat(List<ChatMessage> history, TaskContext ctx) =>
      throw UnimplementedError();

  @override
  Future<DailyReview> dailyReview(DayLog log) => throw UnimplementedError();
}
