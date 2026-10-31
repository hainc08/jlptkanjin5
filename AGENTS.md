# Bàn giao — Kanji Flashcard (repo hainc08/jlptkanjin5)

## Dùng với công cụ nào
- File này (`AGENTS.md`) là **bản gốc** bối cảnh dự án, dùng chung cho Google Antigravity và Claude Code (`CLAUDE.md` chỉ trỏ về đây). Cập nhật mục *Trạng thái* / *Việc tiếp theo* ở đây sau mỗi đợt làm việc.
- Skill dự án: `.agents/skills/<tên>/SKILL.md` (Antigravity đọc trực tiếp). Đây là **bản sao** — bản chính nằm trên tài khoản claude.ai; khi sửa quy trình, sửa ở cả hai nơi.
- Các skill có nhắc công cụ riêng của Claude (device_bash, git bundle, Artifact…): trong IDE chạy trực tiếp trên máy thì bỏ qua phần đồng bộ đó, cứ chạy lệnh `flutter`/`git` bình thường.
- Môi trường: Windows, Flutter tại `C:\Users\admin\develop`, Python có sẵn (in console chỉ dùng ASCII). Bản đồ tổng: `D:\100.JLPT\README.md`.


## Cấu trúc
- Một app gộp 5 cấp, build bằng `apps/n5/config.json` (APP, APP_NAME, STORE_NAME, BUNDLE_ID, VERSION, IOS_PROFILE, mã AdMob) qua `--dart-define-from-file`; `lib/app_config.dart` đọc. Màu nhấn đi theo cấp đang học (`JlptLevel.color`).
- `lib/data/jlpt_level.dart`: enum `JlptLevel` (n5..n1) với dữ liệu đóng sẵn: `kanji_n5.dart` 104 chữ, `kanji_n4.dart` 176 chữ, `kanji_n3.dart` 276 chữ, `kanji_n2.dart` 228 chữ, `kanji_n1.dart` 258 chữ — tổng 1.042 chữ không trùng. `kanjiOf(level)` trong `levels.dart` trả bộ đang dùng; `LevelData` giữ 5 `KanjiStore`.
- `lib/data/progress_store.dart`: tiến độ từng chữ (đúng 3 lần liên tiếp = đã thuộc), chuỗi ngày, số chữ hôm nay — chỉ lưu SharedPreferences.
- `lib/data/kanji_store.dart`: tải `https://hainc08.github.io/jlpt-content/kanji/<app>.json` (repo `D:\100.JLPT\content`), ETag, cache SharedPreferences, kiểm tra hợp lệ (≥20 chữ, không trùng chữ/nghĩa); tự đồng bộ ≤6 giờ/lần, nút ⟳ ở Cài đặt → Bộ dữ liệu. Sửa chữ trên GitHub là app cập nhật, không cần build lại.
- `tools/export_kanji_json.py ../../content/kanji` xuất .dart → JSON.
- `tools/configure_native.py <app>` đặt tên/bundle/icon native; `tools/check_metadata.py`, `app_info.py`, `write_export_options.py`.
- `apps/<app>/store/...`, `apps/<app>/icons/...`; trang chính sách: `docs/<app>/privacy-policy.html` (GitHub Pages).
- CI: `.github/workflows/ci.yml` (matrix n5). Release: `release.yml` — tag `n5-v1.1.0` (tag `v*` cũ = n5) hoặc chạy tay với input `app` (chỉ n5), `platform`. Fastlane đọc `ENV["APP"]`.

## Trạng thái (31/10/2026) — app gộp
- Apple từ chối N1–N5 theo Guideline 4.3 (Spam) / 4.2.6 vì 5 app chung một binary. Hướng xử lý: **gộp thành một app "Kanji JLPT - Flashcard N5–N1"** dùng lại bundle N5 (`com.manabihub.kanjin5`), bản 1.1.0.
- Thiết kế: `docs/superpowers/specs/2026-10-31-kanji-jlpt-merged-app-design.md`; kế hoạch: `docs/superpowers/plans/2026-10-31-kanji-jlpt-merged-app.md`.
- Code ở worktree `D:\100.JLPT\apps\kanji_jlpt` (nhánh `feat/merged-app`): 5 cấp (`lib/data/jlpt_level.dart`, `level_data.dart`), tiến độ lưu trên máy (`progress_store.dart`), Splash → Chào hỏi → 3 tab Trang chủ / Các cấp / Cài đặt, theme Wabi-Sabi (Noto Serif + Be Vietnam Pro), icon mới (`tools/make_merged_icon.py`).
- `apps/n4..n1` chỉ còn để lưu trữ; CI và release chỉ build `n5`.

## Trạng thái cũ (30/10/2026)
- **N5**: iOS đã nộp (審査待ち). Android đã có.
- **N4** (`com.manabihub.kanjin4`):
  - **iOS**: Đã build bản có đồng bộ dữ liệu từ xa (Build 8), điền đầy đủ metadata + 10 screenshot và gửi Apple duyệt (`Waiting for Review` / 審査待ち).
  - **Android**: Đã đẩy bản build mới nhất lên Closed testing (Alpha) đã duyệt.
- **GitHub Pages (`jlpt-content`)**: Đã push `kanji/n5.json`, `n4.json`, `n3.json`, `n2.json`, `n1.json` hoạt động (`200 OK`).
- **N3, N2, N1** (`com.manabihub.kanjin3..kanjin1`):
  - **iOS (App Store Connect)**:
    - Cả 3 app (N3: `6828317163`, N2: `6828343585`, N1: `6828343591`) nhận cùng một phản hồi từ Apple: *Guideline 2.1 - Information Needed - New App Submission* (do tài khoản Apple mới có limited review history).
    - **Không phải lỗi crash hay lỗi code**. Apple yêu cầu giải trình 6 câu hỏi (mục đích, đối tượng, cách truy cập, dịch vụ ngoài, vùng miền, bản quyền) và video quay màn hình (screen recording).
    - Đã chuẩn bị sẵn mẫu giải trình chuẩn 6 câu hỏi và cập nhật vào `apps/{n1..n5}/store/ios/metadata/review_information/notes.txt`.
  - **Android (Google Play Console)**:
    - N1, N4, N5: Đã duyệt track Closed testing, đang chờ tester opt-in 14 ngày.
    - N3: Đang chờ hoàn tất form AD_ID và bấm "Gửi 14 thay đổi xem xét".
    - N2: Cần điền AD_ID, tạo bản phát hành Closed testing và gửi duyệt.
- Play Console tài khoản **D_Monkey** (`/console/u/1/`).
  - App N5 id: `4973817237859693440`
  - App N4 id: `4974739520135758241`
  - App N3 id: `4974234468745789241`
  - App N2 id: `4975864356603322809`
  - App N1 id: `4973223569641456527`
- Thử nghiệm khép kín: cần Google Group testers (người dùng tạo) + 12 tester thật.
- Working tree có thay đổi android/ cục bộ chưa commit (do configure_native) — đừng reset.

## Quy tắc
- Không đưa mật khẩu/khoá vào chat hay repo: khoá ở `D:\100.JLPT\_secrets` và GitHub Secrets (`PLAY_SERVICE_ACCOUNT_JSON`, …).
- Khai báo pháp lý/đồng ý điều khoản/cấp quyền trên store: người dùng tự bấm.
- Claude chưa có quyền push GitHub (chưa cài Claude GitHub App) → commit cục bộ, người dùng tự `git push`.

## Việc tiếp theo (app gộp, nhánh `feat/merged-app`)
- Người dùng điền câu 4 (beta test thật) trong `apps/n5/store/ios/metadata/review_information/notes.txt`.
- Chụp lại screenshot store (iOS `apps/n5/store/ios/screenshots`, Android `apps/n5/store/android/vi/images`) và feature graphic theo giao diện mới — ảnh hiện tại vẫn là app N5 cũ.
- Merge `feat/merged-app` vào `main`, push, release tag `n5-v1.1.0`.
- App Store Connect: rút N4, N3, N2, N1 khỏi review; gửi N5 1.1.0 kèm trả lời 4.3 (nội dung notes.txt) trong Resolution Center.
- Google Play: quyết định dừng/gỡ N4–N1, đẩy N5 1.1.0.
- Build Android trên Windows: pub cache (ổ C) khác ổ với dự án (ổ D) làm Kotlin incremental lỗi → build với `GRADLE_OPTS="-Dorg.gradle.project.kotlin.incremental=false"`.
