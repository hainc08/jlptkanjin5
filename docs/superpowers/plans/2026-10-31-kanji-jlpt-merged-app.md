# App gộp Kanji JLPT N5–N1: Kế hoạch thực hiện

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Biến app Flutter một-cấp hiện có thành một app duy nhất có 5 cấp N5–N1, có dashboard tiến độ lưu trên máy, phát hành dưới bundle `com.manabihub.kanjin5`, phiên bản 1.1.0.

**Architecture:**
- Giữ kiến trúc hiện có: `ChangeNotifier` + `InheritedNotifier`, lưu bằng `SharedPreferences`.
- Thêm `JlptLevel` (enum mô tả 5 cấp), `LevelData` (5 `KanjiStore`), `ProgressStore` (tiến độ từng chữ).
- Giao diện mới: thanh điều hướng 3 tab (Trang chủ / Các cấp / Cài đặt). `TestScreen` nhận cấp làm tham số và ghi tiến độ sau mỗi câu.

**Tech Stack:** Flutter (Dart ≥ 3.6), shared_preferences, http, google_mobile_ads, flutter_test.

**Spec:** `docs/superpowers/specs/2026-10-31-kanji-jlpt-merged-app-design.md` (đọc kèm). Ảnh mockup: `docs/superpowers/specs/2026-10-31-mockups/*.png`.

## Global Constraints

### Nơi làm việc
- Làm trong worktree `D:\100.JLPT\apps\kanji_jlpt`, nhánh `feat/merged-app`, tạo từ `main`.
- Không sửa thư mục `D:\100.JLPT\apps\kanji_flashcard`.

### Store và cấu hình
- Tên trên store: `Kanji JLPT - Flashcard N5–N1`.
- Tên dưới icon (`APP_NAME`): `Kanji JLPT`.
- `VERSION`: `1.1.0`.
- Bundle/package: `com.manabihub.kanjin5`. Mã AdMob giữ nguyên như trong `apps/n5/config.json`.

### Nội dung và quy tắc tiến độ
- Thứ tự cấp: N5, N4, N3, N2, N1.
- Màu cấp: N5 `#2E7D32`, N4 `#1565C0`, N3 `#00897B`, N2 `#E65100`, N1 `#C62828`.
- Nhãn mô tả cấp: N5 "Mới bắt đầu", N4 "Cơ bản", N3 "Trung cấp", N2 "Trung cao", N1 "Cao cấp".
- "Đã thuộc" = đúng 3 lần liên tiếp. Gợi ý sang cấp kế tiếp khi cấp đang học đạt ≥ 80% và không phải N1.
- Tiến độ chỉ lưu trên máy, không có mạng hay tài khoản. Cả 5 cấp miễn phí.

### Giao diện
- Nền sáng `#FBF9F4`, chữ `#1F1E1C`, viền `#E5DFD3`.
- Font Noto Serif (Latin) cho tiêu đề, Be Vietnam Pro cho giao diện, đóng gói trong `assets/fonts/`.
- Kanji dùng font hệ thống với `locale: kJapanese` (đã có trong `theme.dart`).
- Mọi chữ hiển thị là tiếng Việt.
- Không làm: thẻ hồ sơ, icon hoa/lấp lánh, tên "Hán Tự Học", số nét, "BÀI 12", nhãn 「本気」/「学びの道」, sao lưu đám mây, âm thanh, cỡ chữ, mục tiêu ngày.

### Quy trình
- Commit trên nhánh `feat/merged-app`, không push. Người dùng tự push.
- Commit message kết thúc bằng `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Chạy test: `flutter test --dart-define-from-file=apps/n5/config.json`. Flutter ở `C:\Users\admin\develop`.

## Review Focus

1. **Bộ dữ liệu tải từ xa bỏ hoặc đổi chữ.** Tiến độ còn lưu chữ cũ. % và "Cần ôn lại" phải chỉ tính trên chữ đang có trong cấp, không chia sai và không hiện chữ "ma". Test ở Task 2 và Task 3.
2. **Dữ liệu tiến độ trong SharedPreferences bị hỏng** (JSON lỗi). App phải coi như trống, không crash khi mở. Test ở Task 2.
3. **Qua nửa đêm, bỏ một ngày, đồng hồ máy lùi.** Chuỗi ngày và "Hôm nay" phải đúng theo ngày lịch địa phương, không âm, không crash. Test ở Task 2.
4. **Số câu "Tất cả" (`questionCount == 0`), hoặc mọi chữ đều đã thuộc.** Quiz vẫn hỏi đủ chữ của cấp và không rỗng. Test ở Task 3.
5. **"Ôn câu sai" và "Ôn các chữ này".** Kết quả của hai luồng này cũng phải được ghi vào tiến độ đúng cấp. Test ở Task 7.

---

### Task 1: Worktree, mô tả cấp và dữ liệu 5 cấp

**Files:**
- Create: `lib/data/jlpt_level.dart`, `lib/data/level_data.dart`
- Modify: `lib/data/levels.dart`, `lib/main.dart`, `test/widget_test.dart` (đổi tên thành `test/data_test.dart`)
- Test: `test/data_test.dart`, `test/level_data_test.dart`

**Interfaces:**
- Produces:
  - `enum JlptLevel { n5, n4, n3, n2, n1 }` với các getter:
    - `String id` (`'n5'`…)
    - `String label` (`'N5'`…)
    - `String description` (nhãn mô tả cấp)
    - `Color color`
    - `List<Kanji> bundled`
    - `JlptLevel? get next` (N5→N4…N2→N1, N1→null)
    - `static JlptLevel? fromId(String? id)`
  - `class LevelData`:
    - `LevelData({Map<JlptLevel, KanjiStore>? stores})`
    - `static LevelData? current`
    - `Future<void> init()`
    - `List<Kanji> kanjiOf(JlptLevel l)`
    - `KanjiStore storeOf(JlptLevel l)`
    - `Future<void> maybeSyncAll()`
    - `Future<int> syncAll()` (trả 1 nếu có cấp nào có dữ liệu mới, -1 nếu mọi cấp đều lỗi, 0 nếu không thì)
  - `List<Kanji> kanjiOf(JlptLevel l)` (top-level trong `levels.dart`): `LevelData.current?.kanjiOf(l) ?? l.bundled`.

- [ ] **Step 1: Tạo worktree**
  - Chạy (Git Bash, trong `D:\100.JLPT\apps\kanji_flashcard`): `git worktree add ../kanji_jlpt -b feat/merged-app main`
  - Sau đó trong `D:\100.JLPT\apps\kanji_jlpt` chạy `python tools/configure_native.py n5` rồi `flutter pub get`.
  - Kết quả mong đợi: `flutter test --dart-define-from-file=apps/n5/config.json` chạy xanh với các test hiện có.

- [ ] **Step 2: Viết test lỗi**
  - Trong `test/level_data_test.dart`:
    - `JlptLevel.values.map((l) => l.id)` == `['n5','n4','n3','n2','n1']`
    - `JlptLevel.n3.bundled.length` == 276
    - `JlptLevel.n2.next` == `JlptLevel.n1`
    - `JlptLevel.n1.next` == null
    - `JlptLevel.fromId('n4')` == `JlptLevel.n4`
    - `JlptLevel.fromId('x')` == null
    - `JlptLevel.n5.color` == `Color(0xFF2E7D32)`
    - `LevelData` tạo bằng `KanjiStore` giả (prefs `SharedPreferences.setMockInitialValues({})`, `MockClient` trả 404) thì `kanjiOf(JlptLevel.n1)` trả bộ đóng sẵn của N1.
    - `storeOf(JlptLevel.n2).app` == `'n2'`
  - Trong `test/data_test.dart`: bỏ test `appKanji khớp với app đang build`, thêm test `kanjiOf(l)` không rỗng cho cả 5 cấp.

- [ ] **Step 3: Chạy test, kiểm tra thấy lỗi**
  - Chạy: `flutter test test/level_data_test.dart --dart-define-from-file=apps/n5/config.json`
  - Mong đợi: FAIL, vì `JlptLevel` chưa được định nghĩa.

- [ ] **Step 4: Cài đặt**
  - Tạo `JlptLevel` trong `jlpt_level.dart`.
  - `LevelData` trong `level_data.dart` tạo 5 `KanjiStore(app: l.id, bundled: l.bundled)`.
  - Trong `levels.dart`: xóa `bundledKanji` và `appKanji`, thay bằng `kanjiOf`. Vẫn `export 'kanji.dart'` và `jlpt_level.dart`.
  - `main.dart` tạo `LevelData`, `await init()`, gán `LevelData.current`, rồi `unawaited(maybeSyncAll())`.
  - Các chỗ còn dùng `appKanji`, `AppConfig.level` (`test_screen`, `result_screen`, `settings_screen`, `splash_screen`) tạm thời đổi thành `kanjiOf(JlptLevel.n5)` hoặc `'N5'` để biên dịch được. Các task sau sẽ thay hẳn.
  - Giữ biến `KanjiStore.current` để không gãy `kanji_store_test.dart`, nhưng app không dùng nó nữa.

- [ ] **Step 5: Chạy toàn bộ test, kiểm tra xanh**
  - Chạy: `flutter test --dart-define-from-file=apps/n5/config.json`
  - Mong đợi: tất cả PASS.

- [ ] **Step 6: Commit** `feat: mô tả 5 cấp JLPT và dữ liệu theo cấp`

---

### Task 2: ProgressStore (tiến độ lưu trên máy)

**Files:**
- Create: `lib/data/progress_store.dart`
- Test: `test/progress_store_test.dart`

**Interfaces:**
- Consumes: `JlptLevel`, `Kanji`.
- Produces: `class ProgressStore extends ChangeNotifier`
  - `static Future<ProgressStore> load({SharedPreferences? prefs, DateTime Function()? now})`
  - `void record(JlptLevel level, String char, bool correct)`
  - `bool isMastered(JlptLevel level, String char)`
  - `int masteredCount(JlptLevel level, List<Kanji> items)`: chỉ đếm chữ có trong `items`
  - `double percent(JlptLevel level, List<Kanji> items)`: 0..1, trả 0 khi `items` rỗng
  - `List<Kanji> needsReview(JlptLevel level, List<Kanji> items)`: chữ có `wrongCount > 0` và chưa thuộc, có trong `items`, sắp theo lần sai gần nhất (mới trước)
  - `int get todayCount`: số chữ khác nhau đã trả lời trong ngày hôm nay, gộp mọi cấp
  - `int get streakDays`
  - `Future<void> clear()`
  - Hằng số: `static const masteryStreak = 3; static const nextLevelThreshold = 0.8;`

**Lưu trữ:**
- Mỗi cấp một khóa `progress_<id>`. Giá trị là JSON `{char: {"s": streak, "w": wrongCount, "lw": lastWrongMillis, "ls": "yyyy-MM-dd"}}`.
- Khóa `progress_days`: danh sách ngày có học, dạng `yyyy-MM-dd`, giữ tối đa 400 ngày.
- Khóa `progress_today`: `{"d": "yyyy-MM-dd", "c": [chars…]}`, lưu theo `level.id + char` để không trùng giữa các cấp.
- JSON hỏng thì coi như trống.

- [ ] **Step 1: Viết test lỗi** trong `test/progress_store_test.dart`. Dùng `now` giả có thể chỉnh.
  - `đúng 3 lần liên tiếp → đã thuộc`: record đúng ×2 thì `isMastered` false; đúng lần thứ 3 thì true.
  - `sai một lần → mất đã thuộc, vào cần ôn`: sau 3 lần đúng, record sai thì `isMastered` false và `needsReview` chứa chữ đó.
  - `percent chỉ tính chữ đang có`: thuộc 2 chữ, một chữ đã bị bỏ khỏi `items` (4 chữ) thì `masteredCount` == 1 và `percent` == 0.25.
  - `percent khi items rỗng` == 0.
  - `needsReview sắp theo lần sai gần nhất`: sai A lúc 10:00, sai B lúc 11:00 thì kết quả là `[B, A]`.
  - `todayCount đếm chữ khác nhau, reset qua ngày`: trả lời A, A, B thì 2. Chuyển `now` sang ngày hôm sau thì 0.
  - `streak`:
    - Học ngày 1, 2, 3 và `now` là ngày 3 thì 3.
    - `now` là ngày 4 mà chưa học hôm đó thì vẫn 3.
    - `now` là ngày 5 thì 0.
    - Đồng hồ lùi về ngày 2 thì không crash và kết quả ≥ 0.
  - `JSON hỏng → coi như trống`: `setMockInitialValues({'progress_n5': '{oops'})` thì load không ném lỗi và `masteredCount` == 0.
  - `lưu bền`: record, tạo `ProgressStore.load` mới trên cùng prefs thì vẫn đã thuộc.
  - `clear()`: xóa mọi khóa `progress_*` và `todayCount` == 0.

- [ ] **Step 2: Chạy test, kiểm tra thấy lỗi**
  - Chạy: `flutter test test/progress_store_test.dart --dart-define-from-file=apps/n5/config.json`
  - Mong đợi: FAIL.

- [ ] **Step 3: Cài đặt** `ProgressStore` theo đúng interface ở trên.
  - Ngày dùng giờ địa phương của `now()`, định dạng `yyyy-MM-dd` (tự format, không thêm package `intl`).
  - Streak: đếm lùi từ hôm nay. Nếu hôm nay chưa học thì đếm từ hôm qua. Dừng ở ngày đầu tiên bị thiếu.
  - Mỗi lần `record` thì ghi lại khóa của cấp đó và gọi `notifyListeners()`.

- [ ] **Step 4: Chạy test, kiểm tra xanh.** Mong đợi: PASS.

- [ ] **Step 5: Commit** `feat: ProgressStore lưu tiến độ học trên máy`

---

### Task 3: Chọn chữ cho quiz ưu tiên chữ chưa thuộc

**Files:**
- Modify: `lib/logic/quiz.dart`
- Test: `test/quiz_targets_test.dart`

**Interfaces:**
- Consumes: `ProgressStore.isMastered`.
- Produces: `List<Kanji> pickTargets({required List<Kanji> items, required bool Function(Kanji) isMastered, required int count, Random? random})`
  - `count <= 0` nghĩa là trả toàn bộ `items` (đã xáo).
  - Ngược lại: lấy chữ chưa thuộc trước (xáo), sau đó bù chữ đã thuộc (xáo) cho đủ `min(count, items.length)`.

- [ ] **Step 1: Viết test lỗi**
  - `ưu tiên chưa thuộc`: 20 chữ, 15 đã thuộc, `count` 10 thì kết quả có đủ 5 chữ chưa thuộc và độ dài 10.
  - `đủ chưa thuộc thì không lấy chữ đã thuộc`: 20 chữ, 5 đã thuộc, `count` 10 thì không có chữ đã thuộc nào.
  - `count = 0 → hỏi hết`: độ dài == `items.length`.
  - `tất cả đã thuộc`: `count` 10 thì độ dài 10.
  - `items ít hơn count`: 4 chữ, `count` 10 thì độ dài 4.
  - `không trùng chữ` trong kết quả.

- [ ] **Step 2: Chạy, kiểm tra FAIL.**
- [ ] **Step 3: Cài đặt `pickTargets`.** Giữ nguyên `buildQuiz`.
- [ ] **Step 4: Chạy `flutter test`, kiểm tra PASS.**
- [ ] **Step 5: Commit** `feat: quiz ưu tiên chữ chưa thuộc`

---

### Task 4: Cài đặt cấp đang học và Scope

**Files:**
- Modify: `lib/models/app_settings.dart`, `lib/app_scope.dart`, `lib/main.dart`
- Test: `test/app_settings_test.dart`

**Interfaces:**
- Produces:
  - `AppSettings.currentLevel` (`JlptLevel?` get/set), lưu khóa `currentLevel` với giá trị `level.id`. Gán null thì xóa khóa.
  - `class ProgressScope extends InheritedNotifier<ProgressStore>` với `static ProgressStore of(BuildContext)` và `static ProgressStore read(BuildContext)`, giống hệt mẫu của `AppScope`.
  - `main.dart` load `ProgressStore` và bọc `ProgressScope` quanh `AppScope`.

- [ ] **Step 1: Viết test lỗi**
  - Mặc định `currentLevel` == null.
  - Gán `JlptLevel.n3` rồi load lại thì == n3.
  - Gán null thì khóa bị xóa.
  - Khóa chứa giá trị rác `'zz'` thì trả null.
  - Các khóa cũ (`questionCount`, `mode`, `darkMode`, `showHanViet`, `autoNext`) đọc được giá trị có sẵn, để người nâng cấp từ 1.0.x giữ được cài đặt.
- [ ] **Step 2: Chạy, kiểm tra FAIL.**
- [ ] **Step 3: Cài đặt.**
- [ ] **Step 4: Chạy, kiểm tra PASS.**
- [ ] **Step 5: Commit** `feat: lưu cấp đang học, ProgressScope`

---

### Task 5: Theme Wabi-Sabi và font

**Files:**
- Create: `assets/fonts/NotoSerif-Regular.ttf`, `NotoSerif-SemiBold.ttf`, `BeVietnamPro-Regular.ttf`, `BeVietnamPro-SemiBold.ttf`, `assets/fonts/OFL.txt`
- Modify: `pubspec.yaml` (khai báo `fonts:` với family `NotoSerif`, `BeVietnamPro`; đổi `description` thành `"Flashcard Kanji JLPT N5–N1."`), `lib/theme.dart`
- Test: `test/theme_test.dart`

**Interfaces:**
- Produces:
  - `AppColors` gồm `paper = Color(0xFFFBF9F4)`, `ink = Color(0xFF1F1E1C)`, `line = Color(0xFFE5DFD3)`, `night` (nền tối ấm, builder tự chọn), `correct` (giữ nguyên).
  - Bỏ `vermilion` và `plum`.
  - `ThemeData buildTheme(Brightness brightness, {required Color accent})`: `seedColor` = `accent`. Body dùng `fontFamily: 'BeVietnamPro'`. Tiêu đề (`headline*`, `titleLarge`, appBar title) dùng `'NotoSerif'`. Bo góc nút 8.
  - `TextStyle kanjiStyle(double size)`: `fontFamily` null, `locale: kJapanese`, `fontFamilyFallback` theo font hệ thống.

- [ ] **Step 1: Tải font**
  - Nguồn: repo `google/fonts` trên GitHub, giấy phép OFL. Các thư mục `ofl/notoserif` và `ofl/bevietnampro`.
  - Chép kèm `OFL.txt`.
  - Nếu môi trường cần quyền tải file thì hỏi người dùng trước.
- [ ] **Step 2: Viết test lỗi** trong `test/theme_test.dart`:
  - `buildTheme(Brightness.light, accent: JlptLevel.n4.color).scaffoldBackgroundColor` == `Color(0xFFFBF9F4)`.
  - `textTheme.bodyMedium!.fontFamily` == `'BeVietnamPro'`.
  - `textTheme.headlineSmall!.fontFamily` == `'NotoSerif'`.
  - Bản tối có `brightness == Brightness.dark`.
- [ ] **Step 3: Chạy, kiểm tra FAIL.**
- [ ] **Step 4: Cài đặt.**
  - `main.dart` truyền `accent` = màu của `settings.currentLevel ?? JlptLevel.n5`. Đổi cấp thì cả app đổi màu.
  - Sửa mọi chỗ dùng `AppColors.vermilion` thành `Theme.of(context).colorScheme.primary`.
- [ ] **Step 5: Chạy toàn bộ test, kiểm tra PASS.**
- [ ] **Step 6: Commit** `feat: theme Wabi-Sabi, font Noto Serif + Be Vietnam Pro`

---

### Task 6: Splash, Chào hỏi và khung 3 tab

**Files:**
- Modify: `lib/screens/splash_screen.dart`
- Create: `lib/screens/welcome_screen.dart`, `lib/screens/home_shell.dart` (Scaffold + `NavigationBar` 3 tab, giữ trạng thái tab bằng `IndexedStack`), `lib/widgets/level_card.dart` (thẻ cấp dùng chung cho Chào hỏi và Các cấp)
- Test: `test/flow_test.dart`

**Interfaces:**
- Consumes: `AppSettings.currentLevel`, `JlptLevel`, `kanjiOf`.
- Produces:
  - `WelcomeScreen()`.
  - `HomeShell({int initialTab = 0})`. Ba tab: `HomeTab`, `LevelsTab`, `SettingsScreen`. Tạm dùng placeholder `Center(Text(...))` cho `HomeTab` và `LevelsTab`, Task 8 và Task 9 sẽ thay.
  - `LevelCard({required JlptLevel level, double? percent, bool highlighted = false, VoidCallback? onTap})`: hiện 3 chữ mẫu là 3 chữ đầu của `kanjiOf(level)`.
- **Splash** theo mockup `splash.png`:
  - Con dấu đỏ chứa chữ 漢字.
  - Chữ "Kanji JLPT", dòng phụ "Flashcard N5 – N1", năm chấm màu cấp.
  - Cuối màn: "Một sản phẩm từ ManabiHub".
  - Giữ `AdsService.instance.init()` và thời gian 2200 ms.
  - Sau đó đi tới `WelcomeScreen` nếu `currentLevel == null`, ngược lại tới `HomeShell`.
- **Chào hỏi** theo `welcome.png`:
  - "Chào bạn!" và "Bạn muốn bắt đầu từ cấp nào? Đổi lại được trong Cài đặt."
  - 5 `LevelCard`. Bấm thì gán `currentLevel` rồi `pushReplacement(HomeShell())`.
  - Không có nút quay lại hay Bỏ qua.

- [ ] **Step 1: Viết widget test lỗi** trong `test/flow_test.dart`. Bơm `AppScope` + `ProgressScope` với prefs giả. Ads được bỏ qua bằng cách chạy test không có plugin; nếu `AdsService.init` gây lỗi trong test thì thêm cờ để tắt trong test.
  - `lần đầu: Splash → Chào hỏi`: `pump(2300ms)` thì thấy `'Chào bạn!'`.
  - `chọn N4 → vào Trang chủ, đã lưu cấp`: tap thẻ `'N4'` thì `settings.currentLevel == JlptLevel.n4` và thấy `NavigationBar` có 3 nhãn `'Trang chủ'`, `'Các cấp'`, `'Cài đặt'`.
  - `lần sau: Splash → Trang chủ`: prefs có `currentLevel: 'n2'`, `pump(2300ms)` thì không thấy `'Chào bạn!'` và thấy `NavigationBar`.
- [ ] **Step 2: Chạy, kiểm tra FAIL.**
- [ ] **Step 3: Cài đặt.**
- [ ] **Step 4: Chạy, kiểm tra PASS.**
- [ ] **Step 5: Commit** `feat: splash mới, màn Chào hỏi, khung 3 tab`

---

### Task 7: Quiz theo cấp và ghi tiến độ

**Files:**
- Modify: `lib/screens/test_screen.dart`, `lib/screens/result_screen.dart`
- Test: `test/quiz_flow_test.dart`

**Interfaces:**
- Consumes: `pickTargets`, `buildQuiz`, `ProgressScope.read`, `kanjiOf`.
- Produces: `TestScreen({required JlptLevel level, List<Kanji>? targets})` và `ResultScreen({required JlptLevel level, required List<Question> questions, required QuizMode mode})`.
- **Hành vi:**
  - `targets == null`: dùng `pickTargets(items: kanjiOf(level), isMastered: (k) => progress.isMastered(level, k.char), count: settings.questionCount)`, sau đó `buildQuiz(..., count: 0)`.
  - Đáp án nhiễu: `all: kanjiOf(level)`.
  - Trong `_answer`, gọi `ProgressScope.read(context).record(level, q.kanji.char, q.isCorrect)` đúng một lần cho mỗi câu.
  - AppBar hiện nhãn cấp (`level.label`).
  - Bỏ nút mở Cài đặt khỏi màn quiz và màn kết quả; Cài đặt giờ là một tab.
  - Nút back của quiz quay về `HomeShell`.
- **ResultScreen:**
  - Câu khen dùng `level.label` thay cho `AppConfig.level`.
  - "Ôn câu sai" và "Làm bài mới" truyền đúng `level`.
  - Thêm nút "Về trang chủ": `Navigator.popUntil(isFirst)`, hoặc `pushReplacement(HomeShell())` nếu stack trống.

- [ ] **Step 1: Viết widget test lỗi**
  - `trả lời một câu → ghi tiến độ đúng cấp`: mở `TestScreen(level: JlptLevel.n3)`, tap đáp án đúng (đọc `correctIndex` qua text đáp án `answerOf`) thì `progress.needsReview` và streak của chữ đó phản ánh đúng ở N3, không ở N5.
  - `Ôn câu sai cũng ghi tiến độ`: `TestScreen(level: n4, targets: [k])`, trả lời sai thì `needsReview(n4, …)` chứa `k`.
  - `quiz chỉ dùng chữ của cấp`: mọi `q.kanji` thuộc `kanjiOf(level)`.
- [ ] **Step 2: Chạy, kiểm tra FAIL.**
- [ ] **Step 3: Cài đặt.**
- [ ] **Step 4: Chạy toàn bộ test, kiểm tra PASS.**
- [ ] **Step 5: Commit** `feat: quiz theo cấp, ghi tiến độ sau mỗi câu`

---

### Task 8: Tab Trang chủ (dashboard)

**Files:**
- Create: `lib/screens/home_tab.dart`
- Modify: `lib/screens/home_shell.dart` (thay placeholder)
- Test: `test/home_tab_test.dart`

**Interfaces:**
- Consumes: `ProgressScope.of`, `AppScope.of`, `kanjiOf`, `TestScreen`, `JlptLevel.next`, `ProgressStore.nextLevelThreshold`.
- Nội dung theo §5.3 của spec và mockup `home.png`, từ trên xuống:
  1. Dải tiến độ 5 cấp.
  2. Thẻ "Tiếp tục học": nền màu cấp, chữ trắng, "đã thuộc X/Y chữ", %, nút "Học tiếp" → `TestScreen(level: current)`.
  3. Dòng gợi ý "\<cấp> gần xong, thử bắt đầu \<cấp kế> →", chỉ hiện khi % ≥ 0.8 và `next != null`. Bấm thì gán `currentLevel = next`.
  4. Hai thẻ "Chuỗi học tập" (N ngày liên tiếp) và "Hôm nay" (X chữ).
  5. "Cần ôn lại": tối đa 4 ô (chữ, Hán Việt, nghĩa), nút "Ôn các chữ này" → `TestScreen(level: current, targets: needsReview(...))` với toàn bộ danh sách cần ôn. Ẩn khi rỗng.

- [ ] **Step 1: Viết widget test lỗi**
  - `người mới`: `currentLevel` n5, không có tiến độ thì thấy `'Tiếp tục học'` và `'0/104'`, không thấy `'Cần ôn lại'`, không thấy `'gần xong'`.
  - `có chữ sai → hiện Cần ôn lại tối đa 4 ô`: record sai 6 chữ N5 thì thấy `'Cần ôn lại'` và đúng 4 ô chữ.
  - `≥ 80% → gợi ý cấp kế, bấm đổi cấp`: đánh dấu thuộc 84/104 chữ N5 thì thấy `'gần xong'`. Tap thì `currentLevel == JlptLevel.n4`.
  - `N1 ≥ 80% → không gợi ý`.
  - `Học tiếp mở quiz đúng cấp`: tap `'Học tiếp'` thì thấy `TestScreen` có `level == current`.
- [ ] **Step 2: Chạy, kiểm tra FAIL.**
- [ ] **Step 3: Cài đặt.**
- [ ] **Step 4: Chạy, kiểm tra PASS.**
- [ ] **Step 5: Commit** `feat: dashboard Trang chủ`

---

### Task 9: Tab Các cấp

**Files:**
- Create: `lib/screens/levels_tab.dart`
- Modify: `lib/screens/home_shell.dart`
- Test: `test/levels_tab_test.dart`

**Interfaces:**
- Consumes: `LevelCard`, `ProgressStore.percent`, `TestScreen`.
- **Hành vi** theo §5.4 của spec và `levels.png`:
  - 5 `LevelCard` kèm %. Cấp đang học có `highlighted: true` và nhãn "Đang học".
  - Bấm thẻ thì mở `TestScreen(level: l)`, **không** đổi `currentLevel`.

- [ ] **Step 1: Viết test lỗi**
  - Hiển thị đủ 5 nhãn N5…N1.
  - Thẻ của `currentLevel` có `'Đang học'`.
  - Tap thẻ N2 khi đang học N4 thì `TestScreen.level == n2` và `currentLevel` vẫn là n4.
- [ ] **Step 2: Chạy, kiểm tra FAIL.**
- [ ] **Step 3: Cài đặt.**
- [ ] **Step 4: Chạy, kiểm tra PASS.**
- [ ] **Step 5: Commit** `feat: tab Các cấp`

---

### Task 10: Tab Cài đặt

**Files:**
- Modify: `lib/screens/settings_screen.dart`
- Test: `test/settings_test.dart`

**Interfaces:**
- Consumes: `AppSettings`, `ProgressStore.clear`, `LevelData.syncAll`, `AppConfig.version`.
- **Nhóm "Lộ trình & học tập":**
  - "Cấp đang học": chip màu cấp. Bấm mở bottom sheet chọn 5 cấp.
  - "Kiểu câu hỏi": 3 `QuizMode` như hiện tại.
  - "Số câu mỗi lượt".
  - "Gợi ý Hán-Việt".
  - "Tự chuyển câu".
- **Nhóm "Giao diện & hệ thống":**
  - "Chế độ tối" (bật/tắt).
  - "Bộ dữ liệu": hiện "5 cấp · \<tổng> chữ Kanji" và thời điểm đồng bộ gần nhất (lấy giá trị mới nhất trong 5 store). Nút "Cập nhật" gọi `syncAll()` và báo kết quả bằng SnackBar như hiện tại.
  - "Quyền riêng tư quảng cáo": giữ nguyên logic hiện có.
- **Nhóm "Dữ liệu":**
  - "Xóa lịch sử học" màu đỏ `#C62828`.
  - Hộp thoại xác nhận có tiêu đề "Xóa lịch sử học?", nội dung "Toàn bộ tiến độ của 5 cấp sẽ bị xóa.", hai nút "Hủy" và "Xóa".
  - Khi xác nhận: `progress.clear()`, `currentLevel = null`, rồi `Navigator.pushAndRemoveUntil(WelcomeScreen(), (_) => false)`.
- **Cuối màn:** `"Kanji JLPT · Phiên bản ${AppConfig.version}"`.
- Không còn chỗ nào dùng `AppConfig.level`.
- Không cần nút back ở AppBar, vì đây là một tab.

- [ ] **Step 1: Viết test lỗi**
  - Đổi cấp qua bottom sheet sang N1 thì `currentLevel == n1`.
  - Xóa lịch sử, bấm "Hủy" thì tiến độ còn nguyên.
  - Bấm "Xóa" thì `todayCount == 0`, `currentLevel == null` và thấy `'Chào bạn!'`.
  - Thấy `'Phiên bản 1.1.0'` khi chạy với `apps/n5/config.json` đã cập nhật ở Task 11. Nếu Task 11 chưa xong thì so với `AppConfig.version`.
- [ ] **Step 2: Chạy, kiểm tra FAIL.**
- [ ] **Step 3: Cài đặt.**
- [ ] **Step 4: Chạy toàn bộ test, kiểm tra PASS.**
- [ ] **Step 5: Commit** `feat: Cài đặt mới, xóa lịch sử học`

---

### Task 11: Cấu hình, CI, icon, metadata store và tài liệu

**Files:**
- **Cấu hình:**
  - `apps/n5/config.json`: `APP_NAME` `"Kanji JLPT"`, `STORE_NAME` `"Kanji JLPT - Flashcard N5–N1"`, `VERSION` `"1.1.0"`.
  - Bỏ `LEVEL`, `ACCENT`, `ACCENT_DARK`, đồng thời gỡ các field tương ứng khỏi `lib/app_config.dart`.
- **CI:**
  - `.github/workflows/ci.yml`: `matrix.app: [n5]`.
  - `.github/workflows/release.yml`: giới hạn lựa chọn `app` chỉ còn `n5`, không phá tag `v*` / `n5-v*`.
- **Icon:**
  - `apps/n5/icons/*`: icon mới là con dấu hanko đỏ chứa chữ 漢字 trên nền giấy kem, theo splash. Xuất bằng quy trình hiện có.
  - Chạy `python tools/configure_native.py n5`.
- **Metadata store:**
  - `apps/n5/store/ios/metadata/**`: tên, phụ đề, mô tả, từ khóa cho app gộp.
  - `apps/n5/store/android/**`: tương tự.
  - `apps/n5/store/ios/metadata/review_information/notes.txt` viết lại:
    - Giải thích đã gộp 5 app (N5–N1) thành một.
    - Liệt kê dashboard tiến độ, lộ trình, ôn chữ sai.
    - Trả lời 9 câu hỏi 4.3 trung thực.
    - Câu 4 để `[CẦN NGƯỜI DÙNG ĐIỀN: beta test thật]`.
- **Tài liệu:**
  - `AGENTS.md`: cập nhật Trạng thái và Việc tiếp theo.
  - Ghi rằng N4–N1 chỉ còn để lưu trữ, và các việc người dùng phải tự làm trên console: rút N4–N1 khỏi review, quyết định trên Play, gửi N5 1.1.0.
- Test: chạy `python tools/check_metadata.py` (nếu tool hỗ trợ `n5`) và toàn bộ `flutter test`.

- [ ] **Step 1: Sửa config và `app_config.dart`.** Chạy `flutter test`, kiểm tra PASS.
- [ ] **Step 2: Sửa CI và release.**
  - Kiểm tra: `python -c "import yaml,sys;[yaml.safe_load(open(f)) for f in sys.argv[1:]]" .github/workflows/ci.yml .github/workflows/release.yml` không lỗi.
- [ ] **Step 3: Làm icon và chạy `configure_native.py n5`.**
  - Kiểm tra `flutter build apk --debug --dart-define-from-file=apps/n5/config.json` thành công.
- [ ] **Step 4: Sửa metadata, `notes.txt` và `AGENTS.md`.**
  - `check_metadata.py` không báo lỗi độ dài. Tên store 28 ký tự, dưới giới hạn 30.
- [ ] **Step 5: Commit** `chore: cấu hình 1.1.0, CI một app, icon và metadata app gộp`

---

## Ghi chú cho người thực hiện
- **Thứ tự task:** 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → 11. Task 2 và 3 độc lập với nhau, nhưng đều cần Task 1.
- **Màn quiz:** `test_screen.dart` dài khoảng 580 dòng. Chỉ đổi những chỗ nêu ở Task 7, không tái cấu trúc phần thẻ lật và lưới đáp án.
- **Ảnh mockup:** chỉ là tham chiếu bố cục và màu. Các chữ và số trong ảnh (74/176, BÀI 12, số nét…) là dữ liệu giả.
