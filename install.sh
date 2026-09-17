#!/usr/bin/env bash
# =============================================================================
# install.sh
#
# Installs the create-agy-project bootstrapping CLI tool into ~/.local/bin or
# a custom target directory.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_CLI="${SCRIPT_DIR}/bin/create-agy-project"
TARGET_DIR="${HOME}/.local/bin"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dir)
            if [[ -z "${2:-}" ]]; then
                echo "Error: Missing path for --dir argument." >&2
                exit 1
            fi
            TARGET_DIR="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: ./install.sh [--dir <install-directory>]"
            echo "Default install directory: ~/.local/bin"
            exit 0
            ;;
        *)
            echo "Error: Unknown argument $1" >&2
            exit 1
            ;;
    esac
done

if [[ ! -f "$SOURCE_CLI" ]]; then
    echo "Error: Source CLI binary not found at $SOURCE_CLI" >&2
    exit 1
fi

chmod +x "$SOURCE_CLI"
mkdir -p "$TARGET_DIR"

# Resolve absolute path to template directory
REAL_TEMPLATE_DIR="$(cd "${SCRIPT_DIR}" && pwd)"
DEST_FILE="${TARGET_DIR}/create-agy-project"

echo "==> Installing create-agy-project to: $DEST_FILE"
# Install wrapper script pointing to the real template location
cat << EOF > "$DEST_FILE"
#!/usr/bin/env bash
export OPENSPEC_AGY_TEMPLATE_DIR="${REAL_TEMPLATE_DIR}"
exec "${REAL_TEMPLATE_DIR}/bin/create-agy-project" "\$@"
EOF
chmod +x "$DEST_FILE"

echo "✓ Successfully installed create-agy-project."

# Check if TARGET_DIR is in PATH
case ":$PATH:" in
    *":$TARGET_DIR:"*) ;;
    *)
        echo ""
        echo "⚠️  Note: '$TARGET_DIR' is not currently in your system PATH."
        echo "Add it to your shell configuration (e.g. ~/.zshrc or ~/.bashrc):"
        echo "  export PATH=\"\$PATH:$TARGET_DIR\""
        ;;
esac

echo ""
echo "You can now scaffold projects anywhere with:"
echo "  create-agy-project <path-to-new-project>"
