# Bàn giao — Kanji Flashcard (repo hainc08/jlptkanjin5)

## Cấu trúc
- Một codebase, nhiều app: `apps/<level>/config.json` (APP, LEVEL, APP_NAME, STORE_NAME, BUNDLE_ID, VERSION, IOS_PROFILE, ACCENT, mã AdMob) truyền qua `--dart-define-from-file`; `lib/app_config.dart` đọc.
- `lib/data/levels.dart` chọn bộ kanji theo LEVEL (`kanji.dart` N5, `kanji_n4.dart` 176 chữ).
- `tools/configure_native.py <app>` đặt tên/bundle/icon native; `tools/check_metadata.py`, `app_info.py`, `write_export_options.py`.
- `apps/<app>/store/...`, `apps/<app>/icons/...`; trang chính sách: `docs/<app>/privacy-policy.html` (GitHub Pages).
- CI: `.github/workflows/ci.yml` (matrix n5, n4). Release: `release.yml` — tag `n4-v1.0.0` (tag `v*` cũ = n5) hoặc chạy tay với input `app`, `platform`. Fastlane đọc `ENV["APP"]`.

## Trạng thái (29/10/2026)
- **N5**: iOS đã nộp (審査待ち). Android đã có.
- **N4** (`com.manabihub.kanjin4`): Android 1.0.0 trên internal testing; bản closed testing (track Alpha) đã gửi Google duyệt. Còn: iOS release (`app=n4`, `platform=ios`), ASC content rights (người dùng tự làm).
- Play Console tài khoản **D_Monkey** (`/console/u/1/`). App N5 id 4973817237859693440, N4 id 4974739520135758241.
- Thử nghiệm khép kín: cần Google Group testers (người dùng tạo) + 12 tester thật.
- Working tree có thay đổi android/ cục bộ chưa commit (do configure_native) — đừng reset.

## Quy tắc
- Không đưa mật khẩu/khoá vào chat hay repo: khoá ở `D:\100.JLPT\_secrets` và GitHub Secrets (`PLAY_SERVICE_ACCOUNT_JSON`, …).
- Khai báo pháp lý/đồng ý điều khoản/cấp quyền trên store: người dùng tự bấm.
- Claude chưa có quyền push GitHub (chưa cài Claude GitHub App) → commit cục bộ, người dùng tự `git push`.

## Việc tiếp theo
- Thêm N3, N2, N1: dữ liệu kanji + `apps/n3..n1` + AdMob + store listing.
