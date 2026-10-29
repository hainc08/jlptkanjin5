"""Xuất dữ liệu Kanji đóng sẵn (lib/data/kanji_<app>.dart) sang JSON cho repo jlpt-content.

Chạy: python tools/export_kanji_json.py ../../content/kanji          (mọi app)
      python tools/export_kanji_json.py ../../content/kanji n3       (một app)

App tải `https://hainc08.github.io/jlpt-content/kanji/<app>.json`; sửa file đó trên GitHub
là app cập nhật, không cần build lại. Khi phát hành bản app mới, nên đồng bộ ngược nội dung
JSON vào file .dart để bản đóng sẵn cũng mới.
"""

import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
PATTERN = re.compile(r"Kanji\('((?:[^'\\]|\\.)*)', '((?:[^'\\]|\\.)*)', '((?:[^'\\]|\\.)*)', '((?:[^'\\]|\\.)*)', '((?:[^'\\]|\\.)*)'\)")


def export(app, out_dir):
    src = (ROOT / "lib" / "data" / f"kanji_{app}.dart").read_text(encoding="utf-8")
    items = [dict(zip(("char", "hanViet", "meaning", "on", "kun"), (g.replace("\\'", "'") for g in m.groups())))
             for m in PATTERN.finditer(src)]
    data = {"schema": 1, "level": app.upper(), "kanji": items}
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / f"{app}.json").write_text(json.dumps(data, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"{app}: {len(items)} kanji -> {out_dir / (app + '.json')}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    out = pathlib.Path(sys.argv[1])
    apps = sys.argv[2:] or sorted(p.name for p in (ROOT / "apps").iterdir() if (p / "config.json").exists())
    for a in apps:
        export(a, out)
