#!/usr/bin/env python3
"""Cấu hình android/ và ios/ cho một app trong thư mục apps/.

    python3 tools/configure_native.py n4     (hoặc đặt biến môi trường APP=n4)

Không truyền gì thì cấu hình app n5. Chạy lại bao nhiêu lần cũng được (idempotent),
dùng cả ở máy bạn lẫn trên CI. Đọc apps/<app>/config.json để đặt bundle ID, tên app,
AdMob App ID và chép icon của app vào android/ và ios/.
"""
import json
import os
import plistlib
import re
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
APP = (sys.argv[1] if len(sys.argv) > 1 else os.environ.get("APP")) or "n5"
APP_DIR = ROOT / "apps" / APP
if not (APP_DIR / "config.json").exists():
    sys.exit(f"Không thấy apps/{APP}/config.json")
CFG = json.loads((APP_DIR / "config.json").read_text(encoding="utf-8"))

APP_ID = CFG["BUNDLE_ID"]
DISPLAY_NAME = CFG["APP_NAME"]

TEST_ANDROID = "ca-app-pub-3940256099942544~3347511713"
TEST_IOS = "ca-app-pub-3940256099942544~1458002511"

# App chưa có AdMob App ID thật thì dùng App ID test (SDK bắt buộc phải có, nếu không app sẽ crash).
admob_android = CFG.get("ADMOB_APP_ID_ANDROID") or TEST_ANDROID
admob_ios = CFG.get("ADMOB_APP_ID_IOS") or TEST_IOS


def log(msg: str) -> None:
    print(f"[configure_native] {msg}")


# ---------------------------------------------------------------- Android
def configure_android() -> None:
    gradle = ROOT / "android/app/build.gradle.kts"
    manifest = ROOT / "android/app/src/main/AndroidManifest.xml"
    if not gradle.exists():
        if (ROOT / "android/app/build.gradle").exists():
            sys.exit("build.gradle (Groovy) chưa được hỗ trợ: hãy nâng Flutter lên bản mới rồi chạy lại flutter create.")
        log("Bỏ qua Android (chưa có thư mục android/).")
        return

    g = gradle.read_text(encoding="utf-8")
    g = re.sub(r'applicationId\s*=\s*"[^"]*"', f'applicationId = "{APP_ID}"', g)

    if "keystoreProperties" not in g:
        header = (
            "import java.util.Properties\n"
            "import java.io.FileInputStream\n\n"
        )
        loader = (
            "\n// Khóa ký bản phát hành: android/key.properties (CI tự tạo, không commit).\n"
            "val keystoreProperties = Properties()\n"
            'val keystorePropertiesFile = rootProject.file("key.properties")\n'
            "if (keystorePropertiesFile.exists()) {\n"
            "    keystoreProperties.load(FileInputStream(keystorePropertiesFile))\n"
            "}\n\n"
        )
        signing = (
            "android {\n"
            "    signingConfigs {\n"
            '        create("release") {\n'
            '            keyAlias = keystoreProperties["keyAlias"] as String?\n'
            '            keyPassword = keystoreProperties["keyPassword"] as String?\n'
            '            storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }\n'
            '            storePassword = keystoreProperties["storePassword"] as String?\n'
            "        }\n"
            "    }\n"
        )
        g = header + g
        g = g.replace("\nandroid {\n", "\n" + loader + signing, 1)
        g = g.replace(
            'signingConfig = signingConfigs.getByName("debug")',
            'signingConfig = if (keystorePropertiesFile.exists()) signingConfigs.getByName("release") '
            'else signingConfigs.getByName("debug")',
        )
    gradle.write_text(g, encoding="utf-8")
    log(f"build.gradle.kts: applicationId={APP_ID}, ký release bằng key.properties")

    m = manifest.read_text(encoding="utf-8")
    m = re.sub(r'android:label="[^"]*"', f'android:label="{DISPLAY_NAME}"', m, count=1)
    if "android.permission.INTERNET" not in m:
        m = m.replace(
            "<application",
            '<uses-permission android:name="android.permission.INTERNET"/>\n    <application',
            1,
        )
    meta_re = re.compile(
        r'<meta-data\s+android:name="com\.google\.android\.gms\.ads\.APPLICATION_ID"\s+android:value="[^"]*"\s*/>'
    )
    meta = (
        '<meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" '
        f'android:value="{admob_android}"/>'
    )
    if meta_re.search(m):
        m = meta_re.sub(meta, m)
    else:
        m = m.replace("</application>", f"    {meta}\n    </application>", 1)
    manifest.write_text(m, encoding="utf-8")
    log(f"AndroidManifest.xml: label, INTERNET, AdMob App ID {'TEST' if admob_android == TEST_ANDROID else 'thật'}")


# ---------------------------------------------------------------- iOS
SKADNETWORK_IDS = [
    "cstr6suwn9.skadnetwork",  # Google
]


def configure_ios() -> None:
    plist_path = ROOT / "ios/Runner/Info.plist"
    if not plist_path.exists():
        log("Bỏ qua iOS (chưa có thư mục ios/).")
        return

    with plist_path.open("rb") as f:
        p = plistlib.load(f)
    p["CFBundleDisplayName"] = DISPLAY_NAME
    p["GADApplicationIdentifier"] = admob_ios
    p["NSUserTrackingUsageDescription"] = (
        "Dữ liệu này chỉ dùng để hiển thị quảng cáo phù hợp hơn với bạn. "
        "This identifier will be used to deliver more relevant ads to you."
    )
    p["SKAdNetworkItems"] = [{"SKAdNetworkIdentifier": i} for i in SKADNETWORK_IDS]
    p["ITSAppUsesNonExemptEncryption"] = False
    p["UISupportedInterfaceOrientations"] = ["UIInterfaceOrientationPortrait"]
    with plist_path.open("wb") as f:
        plistlib.dump(p, f)
    log(f"Info.plist: tên app, AdMob App ID {'TEST' if admob_ios == TEST_IOS else 'thật'}, ATT, SKAdNetwork, mã hoá")

    podfile = ROOT / "ios/Podfile"
    if podfile.exists():
        pf = podfile.read_text(encoding="utf-8")
        pf = re.sub(r"^#?\s*platform :ios, '[\d.]+'", "platform :ios, '13.0'", pf, count=1, flags=re.M)
        podfile.write_text(pf, encoding="utf-8")

    pbx = ROOT / "ios/Runner.xcodeproj/project.pbxproj"
    if pbx.exists():
        t = pbx.read_text(encoding="utf-8")
        # Chỉ đổi bundle ID của app Runner, giữ nguyên RunnerTests (.RunnerTests).
        t = re.sub(
            r"PRODUCT_BUNDLE_IDENTIFIER = [^;]*?(\.RunnerTests)?;",
            lambda mt: f"PRODUCT_BUNDLE_IDENTIFIER = {APP_ID}{mt.group(1) or ''};",
            t,
        )
        pbx.write_text(t, encoding="utf-8")
        log(f"project.pbxproj: bundle ID {APP_ID}")


# ---------------------------------------------------------------- Icon
def copy_icons() -> None:
    src_android = APP_DIR / "icons/android"
    res = ROOT / "android/app/src/main/res"
    if src_android.exists() and res.exists():
        for d in src_android.iterdir():
            shutil.copytree(d, res / d.name, dirs_exist_ok=True)
        log(f"Icon Android: chép từ apps/{APP}/icons/android")
    src_ios = APP_DIR / "icons/ios/icon-1024.png"
    appicon = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    if src_ios.exists() and appicon.exists():
        shutil.copyfile(src_ios, appicon / "icon-1024.png")
        (appicon / "Contents.json").write_text(json.dumps({
            "images": [{"filename": "icon-1024.png", "idiom": "universal",
                        "platform": "ios", "size": "1024x1024"}],
            "info": {"author": "xcode", "version": 1},
        }, indent=2) + "\n", encoding="utf-8")
        log(f"Icon iOS: chép từ apps/{APP}/icons/ios")


if __name__ == "__main__":
    log(f"App: {APP} ({APP_ID})")
    configure_android()
    configure_ios()
    copy_icons()
