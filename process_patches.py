import json
import os
import urllib.request
from pathlib import Path

RAW_DATASETS_DIR = Path("./raw_datasets")
PATCHES_DIR = Path("./patches")
ORIGIN_PATCHES_DIR = Path("./origin_patches")


def ensure_dirs() -> None:
    """Ensure output directories exist."""
    PATCHES_DIR.mkdir(parents=True, exist_ok=True)
    ORIGIN_PATCHES_DIR.mkdir(parents=True, exist_ok=True)


def download_origin_patch(patch_url: str, dest: Path) -> None:
    """Download the original patch from GitHub (or another host) and save it.

    Uses stdlib urllib to avoid external dependencies.
    """
    if not patch_url:
        return

    try:
        with urllib.request.urlopen(patch_url) as resp:  # type: ignore[call-arg]
            content = resp.read()
    except Exception:
        # Best-effort: skip if we cannot download the patch.
        return

    dest.write_bytes(content)


def process_file(path: Path) -> None:
    """Process a single JSONL file of PR records."""
    with path.open("r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue

            data = json.loads(line)
            org = data["org"]
            repo = data["repo"]
            number = data["number"]

            fix_patch = data.get("fix_patch", "") or ""
            test_patch = data.get("test_patch", "") or ""

            patches = [p for p in (fix_patch, test_patch) if p]
            combined_patch = "\n".join(patches)

            patch_filename = f"{org}_{repo}_{number}.diff"

            # 8. generate the git patch in diff format and save it to ./patches/
            combined_path = PATCHES_DIR / patch_filename
            combined_path.write_text(combined_patch, encoding="utf-8")

            # 9. extract the origin patch from PR and save to ./origin_patches/
            patch_url = data.get("patch_url") or data.get("origin_patch_url")
            if patch_url:
                origin_path = ORIGIN_PATCHES_DIR / patch_filename
                download_origin_patch(patch_url, origin_path)


def main() -> None:
    ensure_dirs()

    # Iterate over all JSONL dataset files under ./raw_datasets
    for entry in RAW_DATASETS_DIR.iterdir():
        if entry.is_file() and entry.suffix == ".jsonl":
            process_file(entry)


if __name__ == "__main__":
    main()
