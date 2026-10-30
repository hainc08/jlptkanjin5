# Bàn giao — Kanji Flashcard (repo hainc08/jlptkanjin5)

## Dùng với công cụ nào
- File này (`AGENTS.md`) là **bản gốc** bối cảnh dự án, dùng chung cho Google Antigravity và Claude Code (`CLAUDE.md` chỉ trỏ về đây). Cập nhật mục *Trạng thái* / *Việc tiếp theo* ở đây sau mỗi đợt làm việc.
- Skill dự án: `.agents/skills/<tên>/SKILL.md` (Antigravity đọc trực tiếp). Đây là **bản sao** — bản chính nằm trên tài khoản claude.ai; khi sửa quy trình, sửa ở cả hai nơi.
- Các skill có nhắc công cụ riêng của Claude (device_bash, git bundle, Artifact…): trong IDE chạy trực tiếp trên máy thì bỏ qua phần đồng bộ đó, cứ chạy lệnh `flutter`/`git` bình thường.
- Môi trường: Windows, Flutter tại `C:\Users\admin\develop`, Python có sẵn (in console chỉ dùng ASCII). Bản đồ tổng: `D:\100.JLPT\README.md`.


## Cấu trúc
- Một codebase, nhiều app: `apps/<level>/config.json` (APP, LEVEL, APP_NAME, STORE_NAME, BUNDLE_ID, VERSION, IOS_PROFILE, ACCENT, mã AdMob) truyền qua `--dart-define-from-file`; `lib/app_config.dart` đọc.
- `lib/data/levels.dart`: `bundledKanji` (dữ liệu đóng sẵn: `kanji_n5.dart` 104 chữ, `kanji_n4.dart` 176 chữ, `kanji_n3.dart` 276 chữ, `kanji_n2.dart` 228 chữ, `kanji_n1.dart` 258 chữ — tổng cộng 1.042 chữ không trùng lặp) và `appKanji` (bản đang dùng).
- `lib/data/kanji_store.dart`: tải `https://hainc08.github.io/jlpt-content/kanji/<app>.json` (repo `D:\100.JLPT\content`), ETag, cache SharedPreferences, kiểm tra hợp lệ (≥20 chữ, không trùng chữ/nghĩa); tự đồng bộ ≤6 giờ/lần, nút ⟳ ở Cài đặt → Bộ dữ liệu. Sửa chữ trên GitHub là app cập nhật, không cần build lại.
- `tools/export_kanji_json.py ../../content/kanji` xuất .dart → JSON.
- `tools/configure_native.py <app>` đặt tên/bundle/icon native; `tools/check_metadata.py`, `app_info.py`, `write_export_options.py`.
- `apps/<app>/store/...`, `apps/<app>/icons/...`; trang chính sách: `docs/<app>/privacy-policy.html` (GitHub Pages).
- CI: `.github/workflows/ci.yml` (matrix n5, n4). Release: `release.yml` — tag `n4-v1.0.0` (tag `v*` cũ = n5) hoặc chạy tay với input `app`, `platform`. Fastlane đọc `ENV["APP"]`.

## Trạng thái (30/10/2026)
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

## Việc tiếp theo
- Tải ảnh Store listing (Icon, Feature Graphic, Screenshots) và upload AAB lên kênh Thử nghiệm khép kín (Closed testing) cho N3, N2, N1 trên Google Play Console -> Bấm Gửi xem xét (Publishing overview).
- Người dùng bấm xác nhận Content Rights trên App Store Connect cho N3, N2, N1.
- Kích hoạt gửi duyệt App Store cho N3, N2, N1 (`submit_review=true`).
- Build lại N5 (bản 1.0.1) để đưa tính năng tải dữ liệu từ xa lên bản N5 (N4 đã có trong Build 8).
