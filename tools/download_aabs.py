import os
import subprocess
import zipfile
import io
import requests

token = subprocess.check_output(['gh', 'auth', 'token'], text=True).strip()
print("Token acquired.")

artifacts = {
    'n3': 12883522109,
    'n2': 12883681672,
    'n1': 12883373095
}

out_dir = r"D:\100.JLPT\apps\kanji_flashcard\build\releases"
os.makedirs(out_dir, exist_ok=True)

for name, aid in artifacts.items():
    dest = os.path.join(out_dir, f"kanji_{name}_release.aab")
    if os.path.exists(dest) and os.path.getsize(dest) > 10000000:
        print(f"{dest} already downloaded ({os.path.getsize(dest)} bytes).", flush=True)
        continue

    print(f"Fetching download URL for {name} ({aid})...", flush=True)
    api_url = f"https://api.github.com/repos/hainc08/jlptkanjin5/actions/artifacts/{aid}/zip"
    resp = requests.get(
        api_url,
        headers={"Authorization": f"Bearer {token}", "Accept": "application/vnd.github+json"},
        allow_redirects=False
    )
    if resp.status_code not in (301, 302, 307, 308):
        print(f"Error fetching {name}: {resp.status_code} {resp.text}", flush=True)
        continue
    
    download_url = resp.headers["Location"]
    print(f"Downloading {name} zip data...", flush=True)
    r2 = requests.get(download_url)
    if r2.status_code != 200:
        print(f"Failed to download blob for {name}: {r2.status_code}", flush=True)
        continue
    
    print(f"Extracting {name} AAB...", flush=True)
    with zipfile.ZipFile(io.BytesIO(r2.content)) as z:
        for fname in z.namelist():
            if fname.endswith(".aab"):
                with open(dest, "wb") as out_f:
                    out_f.write(z.read(fname))
                print(f"Successfully saved {dest}: {os.path.getsize(dest)} bytes", flush=True)

print("ALL AABs READY!")
