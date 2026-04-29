#!/usr/bin/env bash
set -u

usage() {
  cat <<'EOF'
Usage:
  change_paths.sh [-n] [-b] [-e ext1,ext2,...] [project_dir]

Options:
  -n               Dry-run mode
  -b               Backup modified files as .bak
  -e extensions    Comma-separated extensions (default: js,ts,tsx)
  -h               Show help
EOF
}

DRY_RUN=0
MAKE_BACKUP=0
EXTENSIONS="js,ts,tsx"
PROJECT_DIR="."

while getopts ":nbe:h" opt; do
  case "$opt" in
    n) DRY_RUN=1 ;;
    b) MAKE_BACKUP=1 ;;
    e) EXTENSIONS="$OPTARG" ;;
    h) usage; exit 0 ;;
    *)
      usage
      exit 1
      ;;
  esac
done

shift $((OPTIND - 1))
if [ $# -ge 1 ]; then
  PROJECT_DIR=$1
fi

if [ ! -d "$PROJECT_DIR" ]; then
  echo "Error: directory not found: $PROJECT_DIR" >&2
  exit 1
fi

command -v python3 >/dev/null 2>&1 || {
  echo "Error: python3 is required" >&2
  exit 1
}

export LC_ALL=C

python3 - "$PROJECT_DIR" "$DRY_RUN" "$MAKE_BACKUP" "$EXTENSIONS" <<'PY'
import os
import sys
from pathlib import Path
import re
import shutil

project_dir = Path(sys.argv[1])
dry_run = sys.argv[2] == "1"
make_backup = sys.argv[3] == "1"
extensions = [e.strip() for e in sys.argv[4].split(",") if e.strip()]

mapping = {
    "aplicativos": "/aplicativos",
    "suit_express": "/aplicativos/suit-express",
    "suit_label": "/aplicativos/suit-label",
    "suit_pos": "/aplicativos/suit-pos",
    "suit_scale": "/aplicativos/suit-scale",
    "suit_tab": "/aplicativos/suit-tab",
    "suit_waiter": "/aplicativos/suit-waiter",
    "suitable_bi": "/aplicativos/suitable-bi",
    "tablet": "/aplicativos/tablet",
    "totem": "/aplicativos/totem",
    "produto": "/produto",
    "atendimento": "/produto/atendimento",
    "delivery": "/produto/delivery",
    "estoque": "/produto/estoque",
    "financeiro": "/produto/financeiro",
    "impressoes": "/produto/impressoes",
    "integracoes": "/produto/integracoes",
    "kds": "/produto/kds",
    "loja_online": "/produto/loja-online",
    "relatorios": "/produto/relatorios",
    "salao": "/produto/salao",
    "suit_map": "/produto/suit-map",
    "marketing": "/marketing",
    "campanhas": "/marketing/campanhas",
    "coex": "/marketing/coex",
    "crm": "/marketing/crm",
    "gatilhos": "/marketing/gatilhos",
    "suit_bot": "/marketing/suit-bot",
    "novidades": "/novidades",
    "politica_de_privacidade": "/politica-de-privacidade",
    "preco": "/preco",
    "termos_de_uso": "/termos-de-uso",
    "sobre": "/sobre",
    "teste_gratis": "/teste-gratis",
    "contato": "/contato",
    "empresas": "/empresas",
    "blog": "/blog",
}

path_to_key = {v: k for k, v in mapping.items()}

allowed_exts = {f".{ext}" for ext in extensions}

def should_scan(path: Path) -> bool:
    if path.suffix not in allowed_exts:
        return False
    parts = set(path.parts)
    if ".git" in parts or "node_modules" in parts:
        return False
    return True

def process_file(path: Path) -> int:
    try:
        original = path.read_text(encoding="utf-8", errors="surrogateescape")
    except Exception as e:
        print(f"Skipping unreadable file: {path} ({e})")
        return 0

    updated = original
    changes = []

    for key, url in mapping.items():
        replacement = f"page_paths.{key}"

        pattern_double = f'"{re.escape(url)}"'
        pattern_single = f"'{re.escape(url)}'"

        new_updated = re.sub(pattern_double, replacement, updated)
        if new_updated != updated:
            updated = new_updated
            changes.append(f'{url} -> {replacement}')

        new_updated = re.sub(pattern_single, replacement, updated)
        if new_updated != updated:
            updated = new_updated
            changes.append(f'{url} -> {replacement}')

    if not changes:
        return 0

    print(f"Updated: {path}")
    for change in changes:
        print(f"  {change}")

    if dry_run:
        return 1

    if make_backup:
        backup = path.with_suffix(path.suffix + ".bak")
        try:
            shutil.copy2(path, backup)
        except Exception as e:
            print(f"Warning: backup failed for {path}: {e}")

    try:
        path.write_text(updated, encoding="utf-8", errors="surrogateescape")
    except Exception as e:
        print(f"Warning: failed to write {path}: {e}")
        return 0

    return 1

count = 0
for root, dirs, files in os.walk(project_dir):
    dirs[:] = [d for d in dirs if d not in {".git", "node_modules"}]
    for name in files:
        p = Path(root) / name
        if should_scan(p):
            count += process_file(p)

if dry_run:
    print(f"\nDry-run complete. Files with matches: {count}")
else:
    print(f"\nDone. Files updated: {count}")
PY
