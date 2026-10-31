#!/usr/bin/env python3
"""Vẽ icon app gộp Kanji JLPT (con dấu hanko đỏ chứa 漢字 trên nền giấy kem) vào apps/n5/icons.

    python tools/make_merged_icon.py [đường dẫn font Mincho]

Cần Pillow và một font tiếng Nhật kiểu Mincho (mặc định Yu Mincho Demibold của Windows).
Sau đó chạy `python tools/configure_native.py n5` để chép icon vào android/ và ios/.
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "apps" / "n5" / "icons"
FONT = sys.argv[1] if len(sys.argv) > 1 else "C:/Windows/Fonts/yumindb.ttf"

PAPER = (251, 249, 244, 255)
INK = (31, 30, 28, 255)
RED = (198, 40, 40, 255)
SCALE = 4  # vẽ to rồi thu nhỏ cho mịn


def seal(size: int, box: float, ink=INK, red=RED, bg=None) -> Image.Image:
    """Con dấu chiếm tỉ lệ [box] của cạnh ảnh, căn giữa."""
    s = size * SCALE
    im = Image.new("RGBA", (s, s), bg or (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    side = s * box
    x0 = (s - side) / 2
    outer = side * 0.06
    r = side * 0.07
    d.rounded_rectangle([x0, x0, x0 + side, x0 + side], radius=r, outline=red, width=int(outer))
    inset = side * 0.11
    d.rounded_rectangle(
        [x0 + inset, x0 + inset, x0 + side - inset, x0 + side - inset],
        radius=r * 0.5,
        fill=(red[0], red[1], red[2], 26 if bg else 0) if red[3] else None,
        outline=(red[0], red[1], red[2], 140),
        width=max(1, int(side * 0.012)),
    )
    font = ImageFont.truetype(FONT, int(side * 0.36))
    for i, ch in enumerate("漢字"):
        cy = x0 + side * (0.33 + 0.36 * i)
        d.text((s / 2, cy), ch, font=font, fill=ink, anchor="mm")
    return im.resize((size, size), Image.LANCZOS)


def main() -> None:
    # iOS: ảnh vuông không trong suốt, con dấu lớn.
    ios = Image.new("RGBA", (1024, 1024), PAPER)
    ios.alpha_composite(seal(1024, 0.72))
    ios.convert("RGB").save(OUT / "ios" / "icon-1024.png")

    # Android: legacy 48dp và adaptive 108dp (nội dung nằm trong vùng an toàn 66dp).
    densities = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}
    for name, k in densities.items():
        folder = OUT / "android" / f"mipmap-{name}"
        legacy = int(48 * k)
        adaptive = int(108 * k)
        icon = Image.new("RGBA", (legacy, legacy), PAPER)
        icon.alpha_composite(seal(legacy, 0.78))
        icon.convert("RGB").save(folder / "ic_launcher.png")
        Image.new("RGBA", (adaptive, adaptive), PAPER).save(folder / "ic_launcher_background.png")
        seal(adaptive, 0.56).save(folder / "ic_launcher_foreground.png")
        white = (255, 255, 255, 255)
        seal(adaptive, 0.56, ink=white, red=white).save(folder / "ic_launcher_monochrome.png")
    print("[make_merged_icon] done")


if __name__ == "__main__":
    main()
