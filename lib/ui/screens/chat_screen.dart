import 'package:flutter/material.dart';

import '../../controllers/task_controller.dart';
import '../../core/theme.dart';
import '../../models/task.dart';
import '../../services/ai/gateway.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.controller});
  final TaskController controller;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <_Msg>[];
  bool _typing = false;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _input.text).trim();
    if (text.isEmpty) return;
    if (!widget.controller.hasGateway) {
      setState(() {
        _messages.add(_Msg.user(text));
        _messages.add(
          _Msg.assistant(
            'AI not configured. Add your API key in Settings → AI Gateway to use Day Pilot.',
          ),
        );
      });
      _input.clear();
      _scrollToBottom();
      return;
    }
    _input.clear();
    setState(() {
      _messages.add(_Msg.user(text));
      _typing = true;
    });
    _scrollToBottom();

    String reply;
    try {
      final history = _messages
          .map(
            (m) => ChatMessage(
              role: m.isUser ? ChatRole.user : ChatRole.assistant,
              text: m.text,
            ),
          )
          .toList();
      final ctx = TaskContext(
        openTaskCount: widget.controller.openTasks.length,
        todayTaskCount: widget.controller.openTasks
            .where((t) => t.dueDate != null && _isToday(t.dueDate!))
            .length,
      );
      final chunks = widget.controller.gateway!.chat(history, ctx);
      final buf = StringBuffer();
      await for (final c in chunks) {
        buf.write(c.text);
        if (c.done) break;
      }
      if (buf.isEmpty) throw const AiParseException('Empty response from AI');
      reply = buf.toString();
    } catch (e) {
      reply = 'AI request failed: $e';
    }

    if (!mounted) return;
    setState(() {
      _typing = false;
      _messages.add(_Msg.assistant(reply));
    });
    _scrollToBottom();
  }

  static bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kVoid,
        title: const Text(
          'Day Pilot',
          style: TextStyle(fontSize: 20, color: kPaper),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _emptyState()
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: _messages.length + (_typing ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (_typing && i == _messages.length) {
                        return _typingBubble();
                      }
                      return _bubble(_messages[i]);
                    },
                  ),
          ),
          if (_messages.isNotEmpty) _suggestions(),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _typingBubble() => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: kObsidian,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: kFog),
          ),
          SizedBox(width: 8),
          Text('Thinking…', style: TextStyle(fontSize: 13, color: kFog)),
        ],
      ),
    ),
  );

  Widget _suggestions() => Container(
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
    child: Wrap(
      spacing: 8,
      children: [
        _chip('Plan my day'),
        _chip('What’s due today?'),
        _chip('Add task: Buy groceries tomorrow'),
      ],
    ),
  );

  Widget _chip(String label) => ActionChip(
    label: Text(label, style: const TextStyle(fontSize: 12, color: kMist)),
    backgroundColor: kGraphite,
    side: BorderSide.none,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    onPressed: () => _send(label),
  );

  Widget _emptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome_outlined, size: 64, color: kFog),
          const SizedBox(height: 16),
          const Text(
            'Plan your day',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: kBone,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Connect an AI model in Settings to get started.',
            style: TextStyle(fontSize: 14, color: kFog),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => _send('plan my day'),
            style: FilledButton.styleFrom(
              backgroundColor: kAcidLime,
              foregroundColor: kVoid,
              shape: const StadiumBorder(),
            ),
            child: const Text('Plan my day'),
          ),
        ],
      ),
    ),
  );

  Widget _bubble(_Msg m) => Align(
    alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: m.isUser ? kGraphite : kObsidian,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(m.isUser ? 12 : 4),
          topRight: Radius.circular(m.isUser ? 4 : 12),
          bottomLeft: const Radius.circular(12),
          bottomRight: const Radius.circular(12),
        ),
      ),
      child: Text(
        m.text,
        style: TextStyle(fontSize: 15, color: m.isUser ? kMist : kBone),
      ),
    ),
  );

  Widget _inputBar() => Container(
    color: kCarbon,
    padding: EdgeInsets.only(
      left: 16,
      right: 16,
      top: 12,
      bottom: 12 + MediaQuery.of(context).viewPadding.bottom,
    ),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: _input,
            onSubmitted: _send,
            style: const TextStyle(fontSize: 14, color: kMist),
            decoration: const InputDecoration(
              hintText: 'Ask Day Pilot anything…',
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _send(),
          icon: const Icon(Icons.arrow_upward, color: kAcidLime),
        ),
      ],
    ),
  );
}

class _Msg {
  _Msg.user(this.text) : isUser = true;
  _Msg.assistant(this.text) : isUser = false;

  final String text;
  final bool isUser;
}
