/// Cấu hình của từng app, truyền lúc build bằng
/// `--dart-define-from-file=apps/<app>/config.json`.
///
/// Không truyền gì thì mặc định là app N5.
class AppConfig {
  static const id = String.fromEnvironment('APP', defaultValue: 'n5');
  static const level = String.fromEnvironment('LEVEL', defaultValue: 'N5');
  static const name = String.fromEnvironment('APP_NAME', defaultValue: 'Kanji N5');
  static const version = String.fromEnvironment('VERSION', defaultValue: '1.0.0');

  /// Màu nhấn chính và màu đậm đi kèm (dạng 0xAARRGGBB).
  static const accent = int.fromEnvironment('ACCENT', defaultValue: 0xFFD7263D);
  static const accentDark = int.fromEnvironment('ACCENT_DARK', defaultValue: 0xFF8E1B3A);
}
