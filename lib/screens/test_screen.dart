import 'dart:async';

import 'package:flutter/material.dart';

import '../ads/ads_service.dart';
import '../app_scope.dart';
import '../data/levels.dart';
import '../logic/quiz.dart';
import '../models/app_settings.dart';
import '../theme.dart';
import '../widgets/flip_card.dart';
import 'result_screen.dart';
import 'settings_screen.dart';

class TestScreen extends StatefulWidget {
  /// [targets] = null: lấy ngẫu nhiên từ toàn bộ bộ Kanji của app theo số câu trong cài đặt.
  /// [targets] != null: ôn đúng các chữ này (dùng cho "Ôn câu sai").
  const TestScreen({super.key, this.targets});

  final List<Kanji>? targets;

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late List<Question> _questions;
  late QuizMode _mode;
  int _index = 0;
  bool _flipped = false;
  bool _started = false;
  bool _finishing = false;
  Timer? _autoTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _newQuiz();
    }
  }

  void _newQuiz() {
    final settings = AppScope.read(context);
    _autoTimer?.cancel();
    _mode = settings.mode;
    _questions = buildQuiz(
      targets: widget.targets ?? appKanji,
      all: appKanji,
      mode: _mode,
      count: widget.targets != null ? 0 : settings.questionCount,
    );
    _index = 0;
    _flipped = false;
  }

  Question get _q => _questions[_index];
  bool get _isLast => _index == _questions.length - 1;
  int get _correctCount => _questions.where((q) => q.isCorrect).length;

  void _answer(int i) {
    if (_q.answered) return;
    setState(() {
      _q.chosen = i;
      _flipped = true;
    });
    if (AppScope.read(context).autoNext) {
      _autoTimer?.cancel();
      _autoTimer = Timer(const Duration(milliseconds: 1500), () {
        if (mounted) _next();
      });
    }
  }

  Future<void> _next() async {
    _autoTimer?.cancel();
    if (!_q.answered || _finishing) return;
    if (_isLast) {
      _finishing = true;
      await AdsService.instance.onQuizFinished();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(questions: _questions, mode: _mode),
        ),
      );
      return;
    }
    setState(() {
      _index++;
      _flipped = false;
    });
  }

  Future<void> _confirmRestart() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Làm bài mới?'),
        content: const Text('Tiến độ của lượt test hiện tại sẽ bị bỏ.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(96, 44)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Làm mới'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) setState(_newQuiz);
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final total = _questions.length;
    final answered = _q.answered;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Làm bài mới',
          onPressed: _confirmRestart,
        ),
        title: Text('Câu ${_index + 1}/$total'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Cài đặt',
            onPressed: _openSettings,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (_index + (answered ? 1 : 0)) / total,
                        minHeight: 8,
                        backgroundColor: scheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _ScoreChip(correct: _correctCount),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_mode.icon, size: 16, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    _mode.instruction,
                    style: TextStyle(
                      fontSize: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GestureDetector(
                  onTap: answered
                      ? () => setState(() => _flipped = !_flipped)
                      : null,
                  child: FlipCard(
                    key: ValueKey(_index),
                    showBack: _flipped,
                    front: _CardFront(
                      kanji: _q.kanji,
                      mode: _mode,
                      showHanViet: settings.showHanViet,
                    ),
                    back: _CardBack(question: _q),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _OptionsGrid(
                question: _q,
                bigText: _mode == QuizMode.meaningToKanji,
                onSelect: _answer,
              ),
              const SizedBox(height: 14),
              AnimatedOpacity(
                opacity: answered ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: FilledButton.icon(
                  onPressed: answered ? _next : null,
                  icon: Icon(
                    _isLast ? Icons.flag_rounded : Icons.arrow_forward_rounded,
                  ),
                  label: Text(_isLast ? 'Xem kết quả' : 'Câu tiếp theo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({required this.correct});

  final int correct;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.correct.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 16, color: AppColors.correct),
          const SizedBox(width: 4),
          Text(
            '$correct',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.correct,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mặt trước: câu hỏi.
class _CardFront extends StatelessWidget {
  const _CardFront({
    required this.kanji,
    required this.mode,
    required this.showHanViet,
  });

  final Kanji kanji;
  final QuizMode mode;
  final bool showHanViet;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isMeaningPrompt = mode == QuizMode.meaningToKanji;

    return CardShell(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: isMeaningPrompt
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          kanji.meaning,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                        ),
                      )
                    : Text(
                        kanji.char,
                        style: TextStyle(
                          fontSize: 150,
                          height: 1.1,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                          locale: kJapanese,
                        ),
                      ),
              ),
            ),
          ),
          if (showHanViet)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Hán Việt: ${kanji.hanViet}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Mặt sau: thông tin đầy đủ của chữ.
class _CardBack extends StatelessWidget {
  const _CardBack({required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final k = question.kanji;
    final ok = question.isCorrect;
    final resultColor = ok ? AppColors.correct : scheme.error;

    return CardShell(
      borderColor: resultColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: resultColor,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                ok ? 'Chính xác!' : 'Chưa đúng',
                style: TextStyle(
                  color: resultColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    k.char,
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                      locale: kJapanese,
                    ),
                  ),
                  Text(
                    k.hanViet,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    k.meaning,
                    style: TextStyle(fontSize: 18, color: scheme.onSurface),
                  ),
                ],
              ),
            ),
          ),
          _ReadingRow(label: 'On', value: k.on),
          const SizedBox(height: 6),
          _ReadingRow(label: 'Kun', value: k.kun),
        ],
      ),
    );
  }
}

class _ReadingRow extends StatelessWidget {
  const _ReadingRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 44,
          padding: const EdgeInsets.symmetric(vertical: 3),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: scheme.onSecondaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            style: TextStyle(
              fontSize: 16,
              color: scheme.onSurface,
              locale: kJapanese,
            ),
          ),
        ),
      ],
    );
  }
}

enum _OptionState { idle, correct, wrong, dimmed }

class _OptionsGrid extends StatelessWidget {
  const _OptionsGrid({
    required this.question,
    required this.bigText,
    required this.onSelect,
  });

  final Question question;
  final bool bigText;
  final ValueChanged<int> onSelect;

  _OptionState _stateOf(int i) {
    if (!question.answered) return _OptionState.idle;
    if (i == question.correctIndex) return _OptionState.correct;
    if (i == question.chosen) return _OptionState.wrong;
    return _OptionState.dimmed;
  }

  Widget _tile(int i) => Expanded(
        child: _OptionTile(
          label: question.options[i],
          state: _stateOf(i),
          bigText: bigText,
          onTap: () => onSelect(i),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 72,
          child: Row(children: [_tile(0), const SizedBox(width: 10), _tile(1)]),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 72,
          child: Row(children: [_tile(2), const SizedBox(width: 10), _tile(3)]),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.state,
    required this.bigText,
    required this.onTap,
  });

  final String label;
  final _OptionState state;
  final bool bigText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final (Color bg, Color border, Color fg) = switch (state) {
      _OptionState.idle => (
          scheme.surfaceContainerLowest,
          scheme.outlineVariant,
          scheme.onSurface,
        ),
      _OptionState.correct => (
          AppColors.correct.withValues(alpha: 0.14),
          AppColors.correct,
          AppColors.correct,
        ),
      _OptionState.wrong => (
          scheme.error.withValues(alpha: 0.12),
          scheme.error,
          scheme.error,
        ),
      _OptionState.dimmed => (
          scheme.surfaceContainerLowest,
          scheme.outlineVariant.withValues(alpha: 0.5),
          scheme.onSurface.withValues(alpha: 0.4),
        ),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: border,
          width: state == _OptionState.idle ? 1 : 2,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: state == _OptionState.idle ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: bigText ? 34 : 15,
                  fontWeight: bigText ? FontWeight.w600 : FontWeight.w700,
                  height: 1.2,
                  color: fg,
                  locale: kJapanese,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
