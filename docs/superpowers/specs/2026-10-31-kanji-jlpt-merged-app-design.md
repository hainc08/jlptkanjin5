# Thiết kế: App gộp "Kanji JLPT - Flashcard N5–N1"

Ngày: 31/10/2026 · Trạng thái: chờ duyệt

## 1. Vì sao làm

Apple từ chối các app Kanji (N1–N5) theo Guideline 4.3 (Spam) và 4.2.6. Lý do: 5 app dùng chung một binary, chỉ khác bộ dữ liệu `kanji_nX.dart`, tên, màu và icon. Trả lời bằng giải trình không đủ, vì câu 5–7 của Apple (bộ app, có gộp được không, có chung mã không) chỉ trả lời trung thực được là "có".

Hướng xử lý: **gộp thành một app duy nhất chứa cả 5 cấp**, và thêm phần cá nhân hóa (tiến độ học lưu trên máy) để app có giá trị riêng chứ không chỉ là một bộ quiz.

## 2. Mục tiêu

- Một app duy nhất có đủ 5 cấp N5, N4, N3, N2, N1 (tổng 1.042 chữ), tất cả **miễn phí**, vẫn có quảng cáo AdMob như hiện nay.
- **Lần đầu mở app:** người dùng tự chọn cấp bắt đầu theo năng lực.
- **Mỗi lần mở app sau đó:** vào **Trang chủ (dashboard)** để thấy lịch sử học trước đó.
- **Lộ trình N5 → N4 → N3 → N2 → N1** là gợi ý, không khóa cấp nào.
- **Tiến độ chỉ lưu trên thiết bị:** không có tài khoản, không có server.
- Gửi lại App Store với nội dung khác biệt rõ ràng, đủ để qua 4.3.

## 3. Không làm (non-goals)

- Không có đăng nhập, không đồng bộ hoặc sao lưu đám mây.
- Không có mua trong app và không khóa cấp.
- Không có bài test xếp lớp. Người dùng tự chọn cấp.
- Không làm lặp lại ngắt quãng (SRS) kiểu lịch ôn theo ngày, âm thanh phát âm, cỡ chữ kanji hay luyện thứ tự nét.
- Không đổi luật chấm và giao diện cốt lõi của màn quiz (thẻ lật 3D, 3 chế độ hỏi). Chỉ đổi màu theo cấp và thêm việc ghi nhận tiến độ.

**Anti-goal:** làm app trông như 5 app cũ dán lại với nhau, ví dụ chỉ thêm một menu chọn cấp. Phần dashboard và tiến độ phải thật sự là trung tâm.

## 4. Ràng buộc

- Dùng lại app **N5** trên store: bundle ID `com.manabihub.kanjin5` (iOS và Android), App Store app hiện có, Play Console app id `4973817237859693440`. Bundle ID không đổi được, chỉ đổi tên hiển thị.
- **Tên trên store:** `Kanji JLPT - Flashcard N5–N1` (28 ký tự, dưới giới hạn 30). **Tên dưới icon:** `Kanji JLPT`.
- **Mã AdMob:** dùng bộ mã của N5 đang có trong `apps/n5/config.json`.
- **Flutter hiện có:** state dùng `ChangeNotifier` + `InheritedNotifier` (`AppScope`), lưu bằng `SharedPreferences`, không dùng thư viện state hay DB khác. Giữ phong cách này.
- **Chạy offline được hoàn toàn:** dữ liệu 5 cấp đóng sẵn trong app, phần cập nhật từ xa là tùy chọn.
- **Font phải đóng gói trong app** (assets), không tải lúc chạy.

## 5. Luồng màn hình

Thiết kế tham chiếu: dự án Stitch "Kanji JLPT N5-N1" (`10770939098989279081`). Ảnh chụp được lưu kèm ở `docs/superpowers/specs/2026-10-31-mockups/`.

```
Splash (~1,5s)
  ├─ chưa chọn cấp lần nào → Chào hỏi → chọn cấp → Trang chủ
  └─ đã chọn rồi           → Trang chủ
Trang chủ ─┬─ tab Các cấp ─ chọn cấp → Quiz → Kết quả
           └─ tab Cài đặt
```

Thanh điều hướng dưới có 3 tab: **Trang chủ · Các cấp · Cài đặt**.

### 5.1 Splash
- Nền giấy kem, con dấu hanko đỏ chứa chữ 漢字.
- Tên "Kanji JLPT", dòng phụ "Flashcard N5 – N1".
- Năm chấm màu N5→N1 làm hiệu ứng tải.
- Cuối màn: "Một sản phẩm từ ManabiHub".
- **Bỏ** các chi tiết Stitch tự thêm: nhãn 「本気」, dòng 「学びの道」, chữ "Đang khởi tạo tài liệu".
- Thay `splash_screen.dart` hiện có. Thời gian hiển thị giữ như hiện tại.

### 5.2 Chào hỏi (chỉ lần đầu)
- Tiêu đề "Chào bạn!", dòng phụ "Bạn muốn bắt đầu từ cấp nào? Đổi lại được trong Cài đặt."
- Năm thẻ cấp, mỗi thẻ gồm: nền màu cấp nhạt, khối màu bên trái ghi tên cấp, số chữ, nhãn mô tả và 3 chữ mẫu.
  - N5 Mới bắt đầu, N4 Cơ bản, N3 Trung cấp, N2 Trung cao, N1 Cao cấp.
- **Không** có nút Bỏ qua hay dấu ×. Bấm một thẻ thì lưu cấp đang học và sang Trang chủ.

### 5.3 Trang chủ (dashboard)
Từ trên xuống:
1. **Dải tiến độ 5 cấp:** mỗi cấp một thanh màu và % đã thuộc.
2. **Thẻ "Tiếp tục học"** của cấp đang học:
   - Nền màu cấp đặc, chữ trắng.
   - Ghi "đã thuộc X/Y chữ" và % tiến độ.
   - Nút "Học tiếp" vào thẳng quiz của cấp này.
   - Bỏ dòng "BÀI 12" và chữ mẫu của Stitch, vì app không có khái niệm bài.
3. **Hai thẻ thống kê:**
   - "Chuỗi học tập: N ngày liên tiếp" (nền cam nhạt).
   - "Hôm nay: X chữ" (nền lục nhạt).
4. **"Cần ôn lại"** (xem §6):
   - Tối đa 4 ô chữ, mỗi ô có chữ, Hán Việt và nghĩa. **Bỏ số nét**, vì dữ liệu không có.
   - Nút "Ôn các chữ này" mở quiz chỉ gồm danh sách cần ôn của cấp đang học.
   - Ẩn cả mục khi danh sách trống.
5. **Gợi ý cấp tiếp theo:** khi cấp đang học đạt ≥ 80% đã thuộc và chưa phải N1, hiện dòng "N5 gần xong, thử bắt đầu N4 →". Bấm vào thì đổi cấp đang học. Dòng này nằm dưới thẻ "Tiếp tục học".
6. **Người dùng mới chưa học gì:** hiện thẻ "Tiếp tục học" với 0%, ẩn hai mục "Cần ôn lại" và gợi ý. Chuỗi ngày bằng 0.

Màu chủ đạo của Trang chủ (thẻ chính, tab đang chọn, viền ô ôn) là **màu của cấp đang học**.

### 5.4 Các cấp
- Danh sách 5 thẻ. Mỗi thẻ có nền màu nhạt, tên cấp, số chữ, % đã thuộc, thanh tiến độ theo màu cấp và 3 chữ mẫu.
- Cấp đang học có viền đậm và nhãn "Đang học".
- Bấm một thẻ thì vào thẳng quiz của cấp đó. Việc này **không** đổi cấp đang học; chỉ chọn trong Cài đặt hoặc bấm gợi ý mới đổi.

### 5.5 Quiz → Kết quả
- **Không có màn chọn chế độ riêng.** Hiện nay chế độ quiz (`AppSettings.mode`) là một cài đặt chung trong Cài đặt, và `TestScreen` bắt đầu quiz ngay. Giữ nguyên cách này:
  - Bấm thẻ cấp hoặc nút "Học tiếp" thì vào thẳng quiz của cấp đó, dùng chế độ đang chọn.
  - Chế độ quiz vẫn nằm trong Cài đặt (§5.6).
- Dùng lại `test_screen.dart` và `result_screen.dart`, chỉ thêm:
  - Màn nhận vào cấp cần học thay vì đọc `AppConfig`.
  - Màu nhấn theo cấp.
  - Mỗi lần trả lời một câu thì gọi bộ ghi tiến độ (§6).
- **Chọn chữ để hỏi:**
  - Ưu tiên chữ **chưa thuộc** của cấp, theo thứ tự ngẫu nhiên.
  - Nếu số chữ chưa thuộc ít hơn số câu mỗi lượt thì bù bằng chữ đã thuộc.
  - Đáp án nhiễu vẫn lấy ngẫu nhiên trong cả cấp.
  - Thay đổi này nằm ở `buildQuiz` hoặc ở chỗ gọi nó, không đổi luật chấm.
- Nút "Ôn lại câu sai" ở màn Kết quả giữ nguyên.

### 5.6 Cài đặt
- **Nhóm "Lộ trình & học tập":**
  - Cấp đang học (chip màu, bấm thì mở danh sách chọn 5 cấp).
  - Kiểu câu hỏi: 3 chế độ quiz hiện có, như hiện tại.
  - Số câu mỗi lượt (10/20/50/Tất cả, như hiện tại).
  - Gợi ý Hán-Việt (bật/tắt).
- **Nhóm "Giao diện & hệ thống":**
  - Chế độ tối, giữ bật/tắt như hiện tại.
  - Bộ dữ liệu: nút "Cập nhật" kèm thời điểm đồng bộ gần nhất, đồng bộ cả 5 cấp.
- **Nhóm "Dữ liệu":** "Xóa lịch sử học" màu đỏ.
  - Có hộp thoại xác nhận.
  - Xóa toàn bộ tiến độ, chuỗi ngày và cấp đang học, rồi quay về màn Chào hỏi.
- **Cuối màn:** tên app và phiên bản thật (lấy từ `AppConfig.version`). Bỏ dòng "v1.2.0" giả của Stitch.
- Các cài đặt khác đang có trong `AppSettings` (ví dụ `autoNext`) giữ nguyên ở nhóm phù hợp.

## 6. Tiến độ học (lưu trên máy)

Lưu trong `SharedPreferences` bằng một lớp mới (ví dụ `ProgressStore extends ChangeNotifier`), đưa xuống cây widget giống `AppScope`.

**Dữ liệu cho mỗi chữ**, khóa theo `cấp + chữ` vì một chữ có thể không trùng giữa các cấp:
- `streak`: số lần đúng liên tiếp.
- `wrongCount`: tổng số lần sai.
- `lastSeen`: ngày gần nhất.

**Quy tắc:**
- **Đã thuộc:** đúng **3 lần liên tiếp** (ở bất kỳ chế độ nào). Sai một lần thì `streak` về 0, chữ hết "đã thuộc".
- **% của cấp:** số chữ đã thuộc / tổng số chữ của cấp.
- **Cần ôn lại:** chữ có `wrongCount > 0` và chưa thuộc, sắp theo lần sai gần nhất.
- **Hôm nay: X chữ:** số chữ khác nhau đã trả lời trong ngày (giờ máy).
- **Chuỗi ngày:** số ngày liên tiếp có ít nhất một câu trả lời, tính tới hôm nay hoặc hôm qua. Nếu bỏ một ngày thì về 0.
- **Cấp đang học:** lưu một khóa riêng. Khóa này null nghĩa là chưa qua màn Chào hỏi.
- **Người nâng cấp từ bản N5 1.0.x:** chưa có khóa cấp, nên cũng thấy màn Chào hỏi, giống người mới. App đã đổi nhiều nên cho họ chọn lại là hợp lý. Bản cũ không lưu tiến độ nên không có gì cần chuyển. Các cài đặt cũ (số câu, chế độ, chế độ tối, Hán-Việt) dùng chung khóa nên tự giữ nguyên.

Lưu dạng JSON theo cấp, mỗi cấp một khóa (ví dụ `progress_n4`), để không phải ghi lại một blob lớn mỗi câu.

## 7. Dữ liệu 5 cấp

- `bundledKanji` hiện chọn theo `AppConfig.id` sẽ đổi thành **dữ liệu theo cấp**, ví dụ `Map<Level, List<Kanji>>` dùng 5 file `kanji_nX.dart` có sẵn.
- `KanjiStore` đã tham số theo `app`, nên tạo **5 store** (`n5`…`n1`), mỗi store tải `kanji/<cấp>.json` như hiện nay.
  - Đồng bộ nền ≤ 6 giờ/lần áp dụng cho cả 5.
  - Nút "Cập nhật" trong Cài đặt đồng bộ cả 5.
  - Khóa cache hiện có đã chứa tên app (`kanji_remote_src_n5`…), không cần đổi.
- Đáp án nhiễu trong quiz vẫn lấy trong cùng cấp.

## 8. Giao diện chung

- **Phong cách "Wabi-Sabi"** theo Stitch:
  - Nền giấy kem `#FBF9F4`, chữ mực `#1F1E1C`, viền mảnh `#E5DFD3`.
  - Bo góc nhỏ (4–8px), đổ bóng rất nhẹ.
- **Màu cấp:**

  | Cấp | Màu |
  |---|---|
  | N5 | `#2E7D32` |
  | N4 | `#1565C0` |
  | N3 | `#00897B` |
  | N2 | `#E65100` |
  | N1 | `#C62828` |

- **Font:**
  - Noto Serif (bản Latin, có dấu tiếng Việt) cho tiêu đề.
  - Be Vietnam Pro cho chữ giao diện.
  - Cả hai đóng gói vào assets, chỉ cần các độ đậm thực dùng (400, 600).
  - **Chữ kanji và kana dùng font hệ thống** (iOS: Hiragino, Android: Noto CJK). Không đóng gói Noto Serif JP, vì font này nặng nhiều MB, và nếu cắt bớt chữ thì kanji mới tải từ xa sẽ bị lệch font.
- **Không làm các chi tiết trang trí Stitch tự thêm:**
  - Icon hoa bên trái và icon lấp lánh bên phải ở thanh tiêu đề.
  - Thẻ hồ sơ "Người học Hán Tự" ở Cài đặt.
  - Tiêu đề "Hán Tự Học". Thanh tiêu đề dùng tên màn hình, Trang chủ dùng "Kanji JLPT".
- **Chế độ tối:** phải dùng được. Builder tự chọn nền tối ấm (than sumi) và giữ màu cấp.
- `ACCENT` / `ACCENT_DARK` trong config không còn quyết định màu. Màu đi theo cấp.

## 9. Cấu hình, build và store

- Còn **một app**. `apps/n5/config.json` được cập nhật:
  - `APP_NAME` = `Kanji JLPT`
  - `STORE_NAME` = `Kanji JLPT - Flashcard N5–N1`
  - `VERSION` = `1.1.0`
- Các thư mục `apps/n4..n1` giữ lại làm lưu trữ, nhưng gỡ khỏi matrix CI và khỏi hướng dẫn release.
- `AppConfig.level` không còn dùng trong UI.
- Đổi `description` trong `pubspec.yaml`.
- **Icon:** dùng một icon chung mới cho app gộp (con dấu hanko 漢字, theo splash), xuất bằng quy trình icon hiện có (`apps/n5/icons`, `configure_native.py n5`).
- **Metadata store** (`apps/n5/store/...`):
  - Viết lại mô tả, từ khóa, ảnh chụp màn hình theo app gộp.
  - Viết lại `notes.txt`: giải thích đã gộp 5 app thành một, các tính năng tiến độ, và trả lời 9 câu hỏi 4.3 một cách trung thực.
  - **Câu 4 (beta test) cần người dùng cung cấp dữ kiện thật.** Không được bịa phản hồi tester.
- **Việc người dùng tự làm trên console** (ngoài code):
  - Rút N4, N3, N2, N1 khỏi review trên App Store Connect.
  - Quyết định dừng hoặc gỡ N4–N1 trên Google Play.
  - Gửi bản N5 1.1.0 kèm ghi chú trả lời Apple.

## 10. Kiểm thử

- **Unit test cho `ProgressStore`:**
  - Ngưỡng 3 lần đúng liên tiếp.
  - Sai thì reset.
  - Chuỗi ngày qua ranh giới ngày và khi bỏ ngày.
  - "Hôm nay" đếm chữ không trùng.
  - Xóa lịch sử.
- **Unit test chọn dữ liệu theo cấp:** mỗi cấp trả đúng bộ chữ, 5 store dùng đúng khóa.
- **Cập nhật** `widget_test.dart` cho luồng:
  - Lần đầu: Splash → Chào hỏi → Trang chủ.
  - Lần sau: Splash → Trang chủ.
- Giữ nguyên các test hiện có của `kanji_store_test.dart`.

## 11. Để builder tự quyết

- Cấu trúc file và widget cụ thể, cách tách component.
- Chi tiết hiệu ứng chuyển màn hình.
- Bảng màu chế độ tối cụ thể.
- Khoảng trắng và cỡ chữ chi tiết, bám theo ảnh mockup.

## 12. Quyết định do tôi (Claude) đề xuất, người dùng chưa xác nhận riêng

- Ngưỡng "đã thuộc" = đúng 3 lần liên tiếp. Gợi ý sang cấp mới ở ngưỡng 80%.
- Thẻ "Hôm nay" chỉ đếm số chữ, **không có mục tiêu ngày**. Mockup Stitch có "/10 chữ" nhưng người dùng chưa yêu cầu.
- Chế độ tối giữ bật/tắt như hiện nay, không thêm "Tự động".
- Bấm thẻ ở tab Các cấp không đổi cấp đang học.
- Phiên bản `1.1.0`, giữ bộ mã AdMob của N5.
- Không có màn chọn chế độ riêng. Chế độ quiz vẫn nằm trong Cài đặt.
- Quiz ưu tiên chữ chưa thuộc, để % tiến độ tăng có ý nghĩa.
- Kanji dùng font hệ thống, không đóng gói font tiếng Nhật.
- Bỏ thẻ hồ sơ và các icon trang trí Stitch tự thêm.
- Người dùng N5 cũ cũng thấy màn Chào hỏi khi nâng cấp.
