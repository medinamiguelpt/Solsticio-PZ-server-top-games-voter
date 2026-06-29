"""
Fix a nodriver packaging bug that breaks import on newer Python (3.13/3.14):
some auto-generated CDP files contain non-UTF-8 bytes with no encoding
declaration, so Python refuses to import them.

This re-saves ONLY the files that fail a UTF-8 decode as proper UTF-8
(files that already decode as UTF-8 are left untouched, so nothing is
double-encoded). Safe to run multiple times.

Run once after `pip install -r requirements.txt`:
    python patch_nodriver.py
"""
import importlib.util
import pathlib

spec = importlib.util.find_spec("nodriver")
if not spec or not spec.origin:
    raise SystemExit("nodriver is not installed. Run: pip install -r requirements.txt")

pkg = pathlib.Path(spec.origin).parent
fixed = []
for f in pkg.rglob("*.py"):
    b = f.read_bytes()
    try:
        b.decode("utf-8")
    except UnicodeDecodeError:
        f.write_bytes(b.decode("latin-1").encode("utf-8"))
        fixed.append(f.name)

print("Patched:", fixed if fixed else "nothing needed (already OK)")
