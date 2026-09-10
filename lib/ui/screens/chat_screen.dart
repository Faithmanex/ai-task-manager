import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// Day Pilot chat assistant screen (P3 placeholder UI).
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  final _messages = <_Msg>[];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg.user(text));
      // Placeholder echo until gateway chat is wired (P3).
      _messages.add(
        _Msg.assistant(
          'Day Pilot ships in Phase 3 — I\'ll be able to plan your day here.',
        ),
      );
    });
    _input.clear();
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
                    padding: const EdgeInsets.all(24),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) => _bubble(_messages[i]),
                  ),
          ),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.auto_awesome_outlined, size: 64, color: kFog),
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
          'Your AI planning assistant',
          style: TextStyle(fontSize: 15, color: kFog),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _send,
          style: FilledButton.styleFrom(
            backgroundColor: kAcidLime,
            foregroundColor: kVoid,
            shape: const StadiumBorder(),
          ),
          child: const Text('Plan my day'),
        ),
      ],
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
            onSubmitted: (_) => _send(),
            style: const TextStyle(fontSize: 14, color: kMist),
            decoration: const InputDecoration(
              hintText: 'Ask Day Pilot anything…',
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _send,
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
