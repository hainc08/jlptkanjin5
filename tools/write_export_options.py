#!/usr/bin/env python3
"""Tạo ios/ExportOptions.plist từ biến môi trường APPLE_TEAM_ID và IOS_PROFILE_NAME."""
import os
import plistlib
import sys

team = os.environ.get("APPLE_TEAM_ID") or "SLR7396ZXZ"
profile = os.environ.get("IOS_PROFILE_NAME") or "Kanji N5 AppStore"
if not team or not profile:
    sys.exit("Thiếu APPLE_TEAM_ID hoặc IOS_PROFILE_NAME (GitHub → Settings → Variables).")

with open("ios/ExportOptions.plist", "wb") as f:
    plistlib.dump({
        "method": "app-store-connect",
        "teamID": team,
        "signingStyle": "manual",
        "signingCertificate": "Apple Distribution",
        "provisioningProfiles": {"com.manabihub.kanjin5": profile},
        "uploadSymbols": True,
    }, f)
print("Đã tạo ios/ExportOptions.plist")
