import 'package:flutter/material.dart';

import '../ads/ads_service.dart';
import '../ads/banner_ad_slot.dart';
import '../app_scope.dart';
import '../app_config.dart';
import '../data/levels.dart';
import '../models/app_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      bottomNavigationBar: const BannerAdSlot(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const _SectionTitle('Bài test'),
          _Group(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Text(
                  'Số câu mỗi lượt',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
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
                        ButtonSegment(
                          value: n,
                          label: Text(n == 0 ? 'Tất cả' : '$n'),
                        ),
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
            ],
          ),
          const _SectionTitle('Hiển thị'),
          _Group(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Chế độ tối'),
                value: s.darkMode,
                onChanged: (v) => s.darkMode = v,
              ),
              SwitchListTile(
                secondary: const Icon(Icons.lightbulb_outline),
                title: const Text('Gợi ý Hán Việt'),
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
          const _SectionTitle('Thông tin'),
          _Group(
            children: [
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('Bộ dữ liệu'),
                subtitle: Text('JLPT ${AppConfig.level} · ${appKanji.length} chữ Kanji'),
              ),
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
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Phiên bản'),
                subtitle: Text('1.0.0'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Số câu và kiểu câu hỏi áp dụng từ lượt test tiếp theo.',
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
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(children: children),
      ),
    );
  }
}
