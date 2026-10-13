"""Download the Berka / PKDD'99 Czech bank dataset and verify it.

The original host (sorry.vse.cz) is offline, so the files come from a public GitHub
mirror of the untouched .asc files. Each file is checked against a SHA-256 hash and
the documented row count before dbt is allowed to read it.

Usage: python scripts/download_data.py [target_dir]   (default: data/raw)
"""
import hashlib
import sys
import urllib.request
from pathlib import Path

MIRROR = ("https://raw.githubusercontent.com/ekapope/"
          "Banking-Data-Analysis-Reveals-Non-Performing-Customers/master/data/data_berka/")

# file -> (sha256, data rows documented in Berka's "Guide to the Financial Data Set")
FILES = {
    "account.asc":  ("215f4bfcb2520ab8d41154f22b5b294050cc142bb0c7362b05ab6da4742432eb", 4500),
    "card.asc":     ("a4531f8d48f21ed54ba994701547170eac156260fe5c781ec8e2063e1976ba25", 892),
    "client.asc":   ("2b2f5253f21418c4e1366051a988d5e184dd18d3f2159d28dd9fd086819c15e9", 5369),
    "disp.asc":     ("77e08c0988473998abe8b1802446c7c1c1eccb76841c34295baa9b9fdc98d4cc", 5369),
    "district.asc": ("d5422aa7326fde860b7285adee5e454d914f70900b66c6411528b2b8893ba0ce", 77),
    "loan.asc":     ("0cf9fbe7ec2ebb7a2547243d9af5f63f8c064e8f9982917cc000292bcee1fa1e", 682),
    "order.asc":    ("c1d909d5d8a56ce679646c3f56544053ecec4d9688e995758e7a58532e811d00", 6471),
    "trans.asc":    ("111c70dc6626411d1d6547245c318b507e0c2892093f092d579468b71619bd3e", 1056320),
}


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def main(target: Path) -> None:
    target.mkdir(parents=True, exist_ok=True)
    for name, (expected_hash, expected_rows) in FILES.items():
        path = target / name
        if not path.exists() or sha256(path) != expected_hash:
            print(f"downloading {name} ...")
            urllib.request.urlretrieve(MIRROR + name, path)
        if sha256(path) != expected_hash:
            sys.exit(f"checksum mismatch for {name}; refusing to continue")
        rows = sum(1 for _ in path.open("rb")) - 1  # minus header
        if rows != expected_rows:
            sys.exit(f"{name}: {rows} rows, expected {expected_rows}")
        print(f"ok  {name:13} {rows:>9,} rows")


if __name__ == "__main__":
    main(Path(sys.argv[1]) if len(sys.argv) > 1 else Path("data/raw"))
