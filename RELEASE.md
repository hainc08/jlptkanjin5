# Hướng dẫn phát hành – Kanji N5

App: **Kanji N5 - JLPT Flashcard** · Bundle ID / package: `com.manabihub.kanjin5` · Miễn phí, có Google AdMob.

---

## 1. Việc làm tay một lần

### 1.1 GitHub
- [ ] Đẩy code lên repo `hainc08/jlptkanjin5`.
- [ ] Bật GitHub Pages: Settings → Pages → Source: *Deploy from a branch* → `main` / `/docs`.
      Trang chính sách: `https://hainc08.github.io/jlptkanjin5/privacy-policy.html` (repo phải public, hoặc tài khoản GitHub Pro).

### 1.2 AdMob (admob.google.com)
- [x] Đã tạo 2 app và 4 đơn vị quảng cáo (mã đã gắn sẵn trong `lib/ads/ad_ids.dart` và `tools/configure_native.py`):
  - Android App ID `ca-app-pub-2898831437808228~3768187672` · Banner `…/2070916442` · Interstitial `…/1672507372`
  - iOS App ID `ca-app-pub-2898831437808228~8042262578` · Banner `…/3524645092` · Interstitial `…/8444753104`
- [ ] Privacy & messaging: tạo thông điệp **GDPR** (EU/UK) và **IDFA explainer** (iOS), áp dụng cho 2 app trên.
- [ ] Sau khi app lên store: liên kết app với store trong AdMob, và đặt file `app-ads.txt`
      tại gốc website khai báo trên store (xem mục 5).

### 1.3 Apple (developer.apple.com + App Store Connect)
- [ ] Certificates, IDs & Profiles → Identifiers: tạo App ID `com.manabihub.kanjin5`.
- [ ] Tạo chứng chỉ **Apple Distribution** (làm trên Windows bằng openssl, xem mục 2).
- [ ] Profiles: tạo profile **App Store Connect** cho `com.manabihub.kanjin5`, gắn chứng chỉ trên. Ghi lại **tên profile**.
- [ ] App Store Connect → Apps → (+) New App: nền tảng iOS, tên *Kanji N5 - JLPT Flashcard*,
      ngôn ngữ chính **Vietnamese**, bundle ID `com.manabihub.kanjin5`, SKU `kanjin5`.
- [ ] Users and Access → Integrations → App Store Connect API → tạo key quyền **App Manager**.
- [ ] Điền **App Privacy** và **Age Rating** theo mục 4.

### 1.4 Google Play Console
- [ ] Tạo app: *Kanji N5 - JLPT Flashcard*, ngôn ngữ mặc định **Tiếng Việt – vi**, App, Free.
- [ ] Google Cloud Console → tạo **service account** + khóa JSON → Play Console → Users and permissions → mời email service account, cấp quyền phát hành cho app này.
- [ ] **Lần đầu phải upload AAB bằng tay**: chạy workflow Release một lần (job Android sẽ báo lỗi ở bước upload nhưng vẫn lưu file `app-release-aab` trong mục Artifacts) → tải về → Play Console → Testing → Internal testing → Create release → upload.
- [ ] Điền **App content** theo mục 4 (Data safety, Ads, Target audience, Content rating, Advertising ID).
- [ ] Tài khoản Play cá nhân tạo sau 11/2023 phải chạy **closed testing** với số tester và số ngày tối thiểu trước khi lên Production (kiểm tra con số hiện hành trong Play Console).

---

## 2. Tạo khóa trên Windows

Mở **PowerShell** ở một thư mục NGOÀI dự án (vd `D:\100.JLPT\_secrets`). Không đặt các file này trong thư mục dự án.

**Keystore Android** (keytool có sẵn trong Android Studio: `C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe`):
```powershell
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
> Sao lưu file `.jks` và mật khẩu ở nơi an toàn. Mất file này là không cập nhật được app (trừ khi đã bật Play App Signing – mặc định có bật).

**Chứng chỉ iOS** (chạy trong **Git Bash**):
```bash
openssl req -new -newkey rsa:2048 -nodes -keyout dist.key -out dist.csr -subj "/emailAddress=hainc08@gmail.com/CN=Mai Van Hai/C=VN"
# Upload dist.csr ở developer.apple.com → Certificates → (+) → Apple Distribution → tải distribution.cer về
openssl x509 -inform DER -in distribution.cer -out dist.pem
openssl pkcs12 -export -legacy -inkey dist.key -in dist.pem -out dist.p12
```

**Chuyển file sang base64 rồi copy** (PowerShell):
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | Set-Clipboard
```
Làm tương tự cho `dist.p12`, file `.mobileprovision` và file `AuthKey_XXXX.p8`.

---

## 3. GitHub Secrets và Variables

Repo → **Settings → Secrets and variables → Actions**.

**Secrets** (bí mật):

| Tên | Giá trị |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | base64 của `upload-keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | mật khẩu keystore |
| `ANDROID_KEY_PASSWORD` | mật khẩu key (thường giống trên) |
| `ANDROID_KEY_ALIAS` | `upload` |
| `PLAY_SERVICE_ACCOUNT_JSON` | toàn bộ nội dung file JSON service account |
| `ASC_KEY_ID` | Key ID của App Store Connect API key |
| `ASC_ISSUER_ID` | Issuer ID |
| `ASC_KEY_P8_BASE64` | base64 của file `.p8` |
| `IOS_DIST_CERT_P12_BASE64` | base64 của `dist.p12` |
| `IOS_DIST_CERT_PASSWORD` | mật khẩu đặt khi export `.p12` |

**Variables** (không bí mật, nằm trong app):

| Tên | Ví dụ |
|---|---|
| `APPLE_TEAM_ID` | Không bắt buộc: đã gắn sẵn `SLR7396ZXZ` trong code |
| `IOS_PROFILE_NAME` | Không bắt buộc: mặc định `Kanji N5 AppStore` (CI tự tải profile bằng API key) |
| `PLAY_RELEASE_STATUS` | `draft` khi app chưa từng phát hành; xoá biến này sau lần phát hành đầu |

---

## 4. Câu trả lời cho các bảng khai báo

### Apple – App Privacy
- Data collection: **Yes** (do AdMob).
- **Identifiers → Device ID**: dùng cho *Third-Party Advertising*; linked to user: **No**; used for tracking: **Yes**.
- **Usage Data → Advertising Data**: *Third-Party Advertising*; linked: **No**; tracking: **Yes**.
- **Diagnostics → Other Diagnostic Data**: *Third-Party Advertising*, *Analytics*; linked: **No**; tracking: **No**.
- **Location → Coarse Location**: *Third-Party Advertising*; linked: **No**; tracking: **Yes**.

### Apple – Age Rating
Tất cả câu hỏi nội dung: **None / No**. Unrestricted web access: **No**. Kết quả dự kiến: **4+**.

### Google Play – App content
- **Ads**: Yes, my app contains ads.
- **Advertising ID**: Yes – mục đích *Advertising or marketing* (SDK AdMob).
- **Target audience**: chọn **13–15, 16–17, 18+** (không chọn dưới 13 để tránh chính sách Families).
- **Content rating (IARC)**: danh mục *Reference, News, or Educational*; tất cả câu hỏi: **No** → dự kiến *Everyone / 3+*.
- **Data safety**:
  - Collects data: **Yes**; Shares data: **Yes** (với Google để quảng cáo).
  - **Device or other IDs**: collected + shared, mục đích *Advertising or marketing*, *Analytics*; không bắt buộc người dùng? → **Yes, collection is required** (không tắt được trong app).
  - **App activity → App interactions**: collected + shared, *Advertising or marketing*, *Analytics*.
  - **App info and performance → Crash logs, Diagnostics**: collected, *Analytics*.
  - **Location → Approximate location**: collected + shared, *Advertising or marketing*.
  - Data encrypted in transit: **Yes**. Users can request deletion: **No** (app không lưu dữ liệu người dùng).
- **Government apps / Financial / Health**: No.
- Privacy policy URL: `https://hainc08.github.io/jlptkanjin5/privacy-policy.html`

> Kiểm tra lại với mục *Data disclosure* mới nhất của Google cho AdMob trước khi gửi: support.google.com/admob/answer/11048083

---

## 5. app-ads.txt (sau khi lên store)
AdMob yêu cầu file `app-ads.txt` ở **gốc domain** của website khai báo trên store. Với GitHub Pages:
1. Tạo repo public `hainc08.github.io`, bật Pages.
2. Thêm file `app-ads.txt` với dòng AdMob đưa cho bạn (AdMob → Apps → app-ads.txt), dạng
   `google.com, pub-xxxxxxxxxxxxxxxx, DIRECT, f08c47fec0942fa0`.
3. Khai báo website `https://hainc08.github.io` trong trang store (App Store: Marketing URL; Play: Website).

---

## 6. Quy trình mỗi lần phát hành
1. Sửa `version:` trong `pubspec.yaml` (vd `1.1.0+1`; build number do CI tự đánh).
2. Ghi nội dung cập nhật vào
   `android/fastlane/metadata/android/vi/changelogs/default.txt` và
   `ios/fastlane/metadata/vi/release_notes.txt` (từ phiên bản thứ 2).
3. Đẩy tag:
   ```
   git tag v1.1.0
   git push origin v1.1.0
   ```
   → iOS lên **TestFlight**, Android lên **Internal testing**.
4. Test trên máy thật.
5. GitHub → Actions → **Release** → Run workflow → tick **submit_review** → Apple review + Google Production.
