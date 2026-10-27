# Kanji JLPT Flashcard (ManabiHub)

Một bộ code Flutter cho nhiều app luyện Kanji JLPT (Hán Việt, nghĩa tiếng Việt, âm On/Kun):

| App | Cấu hình | Bundle ID | Số chữ |
|---|---|---|---|
| Kanji N5 | `apps/n5/` | `com.manabihub.kanjin5` | 104 |
| Kanji N4 | `apps/n4/` | `com.manabihub.kanjin4` | 176 |

Chọn app khi chạy/build bằng `--dart-define-from-file=apps/<app>/config.json`
và `python tools/configure_native.py <app>`. Cách thêm app mới: xem **RELEASE.md**, mục 0.

- Miễn phí, có quảng cáo Google AdMob (banner ở màn Kết quả và Cài đặt, quảng cáo toàn màn hình sau mỗi 2 lượt test)
- Phát hành tự động bằng fastlane + GitHub Actions: xem **RELEASE.md**

## 4 màn hình
| Màn hình | File | Nội dung |
|---|---|---|
| Splash | `lib/screens/splash_screen.dart` | Logo 漢 có hiệu ứng, tự chuyển sang màn Test sau 2,2 giây |
| Test | `lib/screens/test_screen.dart` | Thẻ flashcard lật 3D, 4 đáp án, thanh tiến độ, điểm |
| Kết quả | `lib/screens/result_screen.dart` | Vòng % điểm, thống kê, danh sách câu sai, nút "Ôn câu sai" |
| Cài đặt | `lib/screens/settings_screen.dart` | Số câu (10/20/30/Tất cả), 3 kiểu câu hỏi, chế độ tối, gợi ý Hán Việt, tự chuyển câu |

Cài đặt được lưu bằng `shared_preferences`.

## Chạy trên Windows
1. Cài Flutter SDK (bản stable) và Android Studio, rồi chạy `flutter doctor` cho tới khi hết lỗi.
2. Giải nén thư mục này, mở PowerShell trong thư mục `kanji_n5_flashcard`.
3. Sinh các thư mục nền tảng rồi cấu hình (bundle ID, tên app, AdMob, ký app):
   ```
   flutter create --org com.manabihub --project-name kanji_n5_flashcard --platforms=android,ios .
   python tools/configure_native.py n5
   ```
   Lệnh `flutter create` **không** ghi đè code trong `lib/`. Khi chạy debug, app dùng mã quảng cáo TEST của Google.
4. Cài thư viện và chạy thử:
   ```
   flutter pub get
   flutter test
   flutter run --dart-define-from-file=apps/n5/config.json   (hoặc apps/n4/config.json)
   ```
   Chạy trên máy ảo Android hoặc điện thoại Android cắm USB.

## Cấu trúc
```
lib/
  main.dart              khởi tạo app, theme sáng/tối
  app_scope.dart         truyền cài đặt xuống cây widget
  theme.dart             màu sắc, kiểu nút
  data/kanji_n5.dart     dữ liệu 104 chữ Kanji N5
  models/app_settings.dart  cài đặt + kiểu câu hỏi
  logic/quiz.dart        tạo câu hỏi và đáp án nhiễu
  ads/                   AdMob: mã quảng cáo, consent, banner, interstitial
  widgets/flip_card.dart thẻ lật 3D
  screens/               4 màn hình
test/widget_test.dart    kiểm tra dữ liệu và logic tạo câu hỏi
tools/                   configure_native.py, check_metadata.py, write_export_options.py
docs/                    trang hỗ trợ + chính sách quyền riêng tư (GitHub Pages)
android/fastlane, ios/fastlane   nội dung store + lệnh upload
.github/workflows/       ci.yml (kiểm tra), release.yml (phát hành)
```

## Bước tiếp theo
- Dùng skill `app-store-assets-designer` để làm icon và screenshot cho store.
- Làm theo **RELEASE.md** để cấu hình khóa và phát hành.
