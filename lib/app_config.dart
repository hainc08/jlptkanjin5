/// Cấu hình build, truyền lúc build bằng
/// `--dart-define-from-file=apps/n5/config.json`.
///
/// App gộp N5–N1 dùng lại bundle của app N5; màu nhấn đi theo cấp đang học (JlptLevel.color).
class AppConfig {
  static const id = String.fromEnvironment('APP', defaultValue: 'n5');
  static const name = String.fromEnvironment('APP_NAME', defaultValue: 'Kanji JLPT');
  static const version = String.fromEnvironment('VERSION', defaultValue: '1.1.0');
}
