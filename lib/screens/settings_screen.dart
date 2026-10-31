import 'package:flutter/material.dart';

import '../ads/ads_service.dart';
import '../ads/banner_ad_slot.dart';
import '../app_config.dart';
import '../app_scope.dart';
import '../data/level_data.dart';
import '../data/levels.dart';
import '../models/app_settings.dart';
import '../progress_scope.dart';
import '../widgets/content_width.dart';

import 'welcome_screen.dart';

/// Màu cho hàng "Xóa lịch sử học" (đỏ son N1).
const _danger = Color(0xFFC62828);

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _pickLevel(BuildContext context) async {
    final s = AppScope.read(context);
    final picked = await showModalBottomSheet<JlptLevel>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final l in JlptLevel.values)
              ListTile(
                key: ValueKey('pick-${l.id}'),
                leading: CircleAvatar(
                  backgroundColor: l.color,
                  child: Text(l.label, style: const TextStyle(color: Colors.white, fontSize: 13)),
                ),
                title: Text('${l.label} · ${l.description}'),
                subtitle: Text('${kanjiOf(l).length} chữ Kanji'),
                trailing: s.currentLevel == l ? Icon(Icons.check_circle, color: l.color) : null,
                onTap: () => Navigator.pop(ctx, l),
              ),
          ],
        ),
      ),
    );
    if (picked != null) s.currentLevel = picked;
  }

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa lịch sử học?'),
        content: const Text('Toàn bộ tiến độ của 5 cấp sẽ bị xóa.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _danger, minimumSize: const Size(96, 44)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await ProgressScope.read(context).clear();
    if (!context.mounted) return;
    AppScope.read(context).currentLevel = null;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final level = s.currentLevel;

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt'), automaticallyImplyLeading: false),
      bottomNavigationBar: const BannerAdSlot(),
      body: ListView(
        padding: contentPadding(context, side: 16, bottom: 32),
        children: [
          const _SectionTitle('Lộ trình & học tập'),
          _Group(
            children: [
              ListTile(
                leading: const Icon(Icons.school_outlined),
                title: const Text('Cấp đang học'),
                trailing: level == null
                    ? const Icon(Icons.chevron_right)
                    : Chip(
                        label: Text(level.label, style: const TextStyle(color: Colors.white)),
                        backgroundColor: level.color,
                        side: BorderSide.none,
                      ),
                onTap: () => _pickLevel(context),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Text(
                  'Số câu mỗi lượt',
                  style: TextStyle(fontWeight: FontWeight.w600, color: scheme.onSurface),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<int>(
                    showSelectedIcon: false,
                    segments: [
                      for (final n in AppSettings.questionCountOptions)
                        ButtonSegment(value: n, label: Text(n == 0 ? 'Tất cả' : '$n')),
                    ],
                    selected: {s.questionCount},
                    onSelectionChanged: (v) => s.questionCount = v.first,
                  ),
                ),
              ),
              const Divider(height: 1),
              for (final m in QuizMode.values)
                ListTile(
                  leading: Icon(m.icon),
                  title: Text(m.label),
                  subtitle: Text(m.description),
                  trailing: s.mode == m
                      ? Icon(Icons.check_circle, color: scheme.primary)
                      : const Icon(Icons.circle_outlined),
                  onTap: () => s.mode = m,
                ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.lightbulb_outline),
                title: const Text('Gợi ý Hán-Việt'),
                subtitle: const Text('Hiện âm Hán Việt trên mặt câu hỏi'),
                value: s.showHanViet,
                onChanged: (v) => s.showHanViet = v,
              ),
              SwitchListTile(
                secondary: const Icon(Icons.fast_forward_outlined),
                title: const Text('Tự chuyển câu'),
                subtitle: const Text('Sang câu tiếp sau 1,5 giây khi đã trả lời'),
                value: s.autoNext,
                onChanged: (v) => s.autoNext = v,
              ),
            ],
          ),
          const _SectionTitle('Giao diện & hệ thống'),
          _Group(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Chế độ tối'),
                value: s.darkMode,
                onChanged: (v) => s.darkMode = v,
              ),
              const _DataTile(),
              FutureBuilder<bool>(
                future: AdsService.instance.privacyOptionsRequired(),
                builder: (context, snap) => snap.data == true
                    ? ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: const Text('Quyền riêng tư quảng cáo'),
                        subtitle: const Text('Thay đổi lựa chọn chia sẻ dữ liệu quảng cáo'),
                        onTap: AdsService.instance.showPrivacyOptions,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          const _SectionTitle('Dữ liệu'),
          _Group(
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline, color: _danger),
                title: const Text('Xóa lịch sử học', style: TextStyle(color: _danger, fontWeight: FontWeight.w600)),
                subtitle: const Text('Đặt lại toàn bộ tiến độ các cấp'),
                onTap: () => _confirmClear(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Kanji JLPT · Phiên bản ${AppConfig.version}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(children: children),
      ),
    );
  }
}

/// Bộ dữ liệu Kanji của 5 cấp: tổng số chữ, lần kiểm tra gần nhất, nút kiểm tra dữ liệu mới.
class _DataTile extends StatefulWidget {
  const _DataTile();

  @override
  State<_DataTile> createState() => _DataTileState();
}

class _DataTileState extends State<_DataTile> {
  bool _syncing = false;

  int get _total => JlptLevel.values.fold(0, (sum, l) => sum + kanjiOf(l).length);

  DateTime? get _lastSync {
    final data = LevelData.current;
    if (data == null) return null;
    DateTime? last;
    for (final l in JlptLevel.values) {
      final t = data.storeOf(l).lastSync;
      if (t != null && (last == null || t.isAfter(last))) last = t;
    }
    return last;
  }

  Future<void> _sync() async {
    final data = LevelData.current;
    if (data == null) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _syncing = true);
    final r = await data.syncAll();
    if (!mounted) return;
    setState(() => _syncing = false);
    messenger.showSnackBar(SnackBar(
      content: Text(r < 0
          ? 'Không tải được dữ liệu mới. Đang dùng bộ hiện có.'
          : (r == 0 ? 'Dữ liệu đã là mới nhất.' : 'Đã cập nhật bộ Kanji ($_total chữ).')),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final last = _lastSync;
    final when = last == null
        ? ''
        : ' · kiểm tra ${last.hour.toString().padLeft(2, '0')}:${last.minute.toString().padLeft(2, '0')} ${last.day}/${last.month}';
    return ListTile(
      leading: const Icon(Icons.menu_book_outlined),
      title: const Text('Bộ dữ liệu'),
      subtitle: Text('5 cấp · $_total chữ Kanji$when'),
      trailing: LevelData.current == null
          ? null
          : _syncing
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
              : IconButton(tooltip: 'Cập nhật', icon: const Icon(Icons.refresh), onPressed: _sync),
    );
  }
}
