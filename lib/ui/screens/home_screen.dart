import 'package:flutter/material.dart';

import '../../controllers/task_controller.dart';
import '../../core/theme.dart';
import '../../models/task.dart';
import '../../services/ai/ai_settings_store.dart';
import '../../services/ai/providers/openai_provider.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

/// Home shell: Today list, quick capture, navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TaskController();
  final _captureController = TextEditingController();
  final _aiSettingsStore = AiSettingsStore();
  bool _parsing = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _initController();
  }

  Future<void> _initController() async {
    final aiConfig = await _aiSettingsStore.load();
    if (aiConfig != null) {
      _controller.gateway = OpenAiProvider(config: aiConfig);
    }
    await _controller.load();
  }

  @override
  void dispose() {
    _captureController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitCapture() async {
    final text = _captureController.text.trim();
    if (text.isEmpty) return;

    if (_controller.hasGateway) {
      setState(() => _parsing = true);
      try {
        final draft = await _controller.parseNaturalLanguage(text);
        if (draft != null && mounted) {
          _captureController.clear();
          await _showDraftReview(draft);
          return;
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('AI parse failed — added as plain task'),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _parsing = false);
      }
    }

    _controller.addTask(
      Task(
        id: 't_${DateTime.now().microsecondsSinceEpoch}',
        title: text,
        createdAt: DateTime.now(),
      ),
    );
    _captureController.clear();
  }

  Future<void> _showDraftReview(TaskDraft draft) async {
    final add = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: kObsidian,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) => _DraftReviewSheet(draft: draft),
    );
    if (add == true) _controller.addFromDraft(draft);
  }

  @override
  Widget build(BuildContext context) {
    final open = _controller.openTasks;
    final done = _controller.completedTasks;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kVoid,
        title: const Text(
          'Today',
          style: TextStyle(fontSize: 24, color: kPaper),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsScreen(
                  store: _aiSettingsStore,
                  onSettingsSaved: (config) {
                    if (config != null) {
                      _controller.gateway = OpenAiProvider(config: config);
                    } else {
                      _controller.gateway = null;
                    }
                  },
                  onDeleteAll: () async {
                    await _controller.deleteAll();
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ),
            ),
            icon: const Icon(Icons.settings_outlined, color: kFog),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(controller: _controller),
              ),
            ),
            icon: const Icon(Icons.forum_outlined, color: kFog),
          ),
        ],
      ),
      body: _controller.isLoaded
          ? ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 96),
              children: [
                Text(
                  '${done.length} of ${_controller.tasks.length} done'
                  '${_controller.hasGateway ? ' · AI ready' : ''}',
                  style: const TextStyle(fontSize: 15, color: kFog),
                ),
                const SizedBox(height: 16),
                if (open.isEmpty && done.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: Column(
                      children: [
                        Icon(Icons.checklist_outlined, size: 64, color: kFog),
                        SizedBox(height: 16),
                        Text(
                          'All clear — add your first task',
                          style: TextStyle(fontSize: 15, color: kFog),
                        ),
                      ],
                    ),
                  ),
                ...open.map((t) => _TaskTile(controller: _controller, task: t)),
                if (done.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Completed',
                      style: TextStyle(fontSize: 13, color: kAsh),
                    ),
                  ),
                  ...done.map(
                    (t) => _TaskTile(controller: _controller, task: t),
                  ),
                ],
              ],
            )
          : const Center(child: CircularProgressIndicator(color: kAcidLime)),
      bottomSheet: _CaptureBar(
        controller: _captureController,
        busy: _parsing,
        onSubmit: _submitCapture,
        onAssistantTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(controller: _controller),
          ),
        ),
      ),
    );
  }
}

class _TaskTile extends StatefulWidget {
  const _TaskTile({required this.controller, required this.task});

  final TaskController controller;
  final Task task;

  @override
  State<_TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<_TaskTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.task;
    final score = widget.controller.score(t);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCarbon,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kGraphite),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _Checkbox(
                checked: t.completed,
                onTap: () => widget.controller.toggleComplete(t),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.title,
                      style: TextStyle(
                        fontSize: 15,
                        color: t.completed ? kAsh : kBone,
                        decoration: t.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (t.dueDate != null)
                      Text(
                        '${t.isOverdue ? 'Overdue · ' : ''}'
                        'Due ${_shortDate(t.dueDate!)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: t.isOverdue ? kCoralRed : kFog,
                        ),
                      ),
                  ],
                ),
              ),
              _priorityDot(t.priority),
              const SizedBox(width: 8),
              Text(
                score.score.round().toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'JetBrainsMono',
                  color: kAsh,
                ),
              ),
              if (t.subtasks.isNotEmpty)
                IconButton(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  icon: Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: kFog,
                    size: 18,
                  ),
                ),
            ],
          ),
          if (_expanded && t.subtasks.isNotEmpty)
            ...t.subtasks.map(
              (s) => Padding(
                padding: const EdgeInsets.fromLTRB(36, 6, 0, 0),
                child: Row(
                  children: [
                    _Checkbox(
                      size: 16,
                      checked: s.completed,
                      onTap: () => widget.controller.toggleSubtask(t, s),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      s.title,
                      style: TextStyle(
                        fontSize: 13,
                        color: s.completed ? kAsh : kMist,
                        decoration: s.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _shortDate(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'today';
    }
    return '${d.month}/${d.day}';
  }

  static Widget _priorityDot(Priority p) => Container(
    width: 6,
    height: 6,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: switch (p) {
        Priority.low => kIrisViolet,
        Priority.medium => kSignalTeal,
        Priority.high => kAcidLime,
      },
    ),
  );
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.checked, required this.onTap, this.size = 22});

  final bool checked;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey('check_${checked.hashCode}_$size'),
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: checked ? kPulseGreen : kSmoke, width: 1.5),
          color: checked ? kPulseGreen : Colors.transparent,
        ),
        child: checked
            ? Icon(Icons.check, size: size * 0.7, color: kVoid)
            : null,
      ),
    );
  }
}

class _CaptureBar extends StatelessWidget {
  const _CaptureBar({
    required this.controller,
    required this.busy,
    required this.onSubmit,
    required this.onAssistantTap,
  });

  final TextEditingController controller;
  final bool busy;
  final VoidCallback onSubmit;
  final VoidCallback onAssistantTap;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              controller: controller,
              onSubmitted: (_) => onSubmit(),
              style: const TextStyle(fontSize: 14, color: kMist),
              decoration: const InputDecoration(
                hintText: "Try 'Email Dana the deck tomorrow 5pm'",
              ),
            ),
          ),
          const SizedBox(width: 8),
          _CircleButton(
            icon: Icons.auto_awesome,
            color: kGraphite,
            foreground: kMist,
            onTap: onAssistantTap,
          ),
          const SizedBox(width: 8),
          _CircleButton(
            icon: busy ? Icons.hourglass_top : Icons.add,
            color: kAcidLime,
            foreground: kVoid,
            onTap: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.color,
    required this.foreground,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: foreground),
        ),
      ),
    );
  }
}

/// AI suggestion card shown before commit — user is the final authority.
class _DraftReviewSheet extends StatelessWidget {
  const _DraftReviewSheet({required this.draft});

  final TaskDraft draft;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: kLavender.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'AI',
                  style: TextStyle(fontSize: 12, color: kLavender),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Suggested task',
                style: TextStyle(fontSize: 13, color: kFog),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            draft.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: kBone,
            ),
          ),
          if (draft.dueDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Due ${draft.dueDate}',
                style: const TextStyle(fontSize: 13, color: kFog),
              ),
            ),
          if (draft.subtasks.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...draft.subtasks.map(
              (s) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '•  ${s.title}',
                  style: const TextStyle(fontSize: 14, color: kMist),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Add task'),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Dismiss'),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
