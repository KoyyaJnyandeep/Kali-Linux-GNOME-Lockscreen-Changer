#!/usr/bin/env sh
# kali-lockscreen-swap.sh — Replace GNOME lock screen blur image on Kali
# Requires: ImageMagick (identify), file

set -eu

# --------- Color helpers (fallback if tput unavailable) ----------
if command -v tput >/dev/null 2>&1; then
  C_RESET="$(tput sgr0)"; C_BOLD="$(tput bold)"
  C_RED="$(tput setaf 1)"; C_GREEN="$(tput setaf 2)"
  C_YELLOW="$(tput setaf 3)"; C_BLUE="$(tput setaf 4)"
  C_MAGENTA="$(tput setaf 5)"; C_CYAN="$(tput setaf 6)"
else
  C_RESET=""; C_BOLD=""
  C_RED=""; C_GREEN=""; C_YELLOW=""; C_BLUE=""
  C_MAGENTA=""; C_CYAN=""
fi

info()    { printf "%s[ℹ]%s %s\n" "$C_CYAN" "$C_RESET" "$1"; }
warn()    { printf "%s[!]%s %s\n" "$C_YELLOW" "$C_RESET" "$1"; }
error()   { printf "%s[✗]%s %s\n" "$C_RED" "$C_RESET" "$1" >&2; }
success() { printf "%s[✓]%s %s\n" "$C_GREEN" "$C_RESET" "$1"; }
title()   { printf "\n%s%s%s%s%s\n" "$C_MAGENTA" "$C_BOLD" "$1" "$C_RESET" ""; }

# --------- Require root (re-exec with sudo) ----------
if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  title "🔐 Kali Lock Screen Wallpaper Swapper"
  warn  "Root privileges required — re-running with sudo…"
  exec sudo -E -- "$0" "$@"
fi

title "🎨 Kali Lock Screen Wallpaper Swapper"

TARGET_DIR="/usr/share/backgrounds/kali"
TARGET_FILE="$TARGET_DIR/login-blurred"

# --------- Check dependencies ----------
need() {
  if ! command -v "$1" >/dev/null 2>&1; then
    error "Missing dependency: $1"
    case "$1" in
      identify) warn "Install ImageMagick:  sudo apt update && sudo apt install imagemagick" ;;
      file)     warn "Install 'file' utility: sudo apt update && sudo apt install file" ;;
    esac
    exit 1
  fi
}
need identify
need file

# --------- Get input image path ----------
IMG_PATH="${1-}"
if [ -z "${IMG_PATH}" ]; then
  printf "%sEnter path to your image (.jpg/.jpeg, 16:9): %s" "$C_BLUE" "$C_RESET"
  IFS= read -r IMG_PATH
fi

if [ -z "${IMG_PATH}" ]; then
  error "No image provided. Aborting."
  exit 1
fi

if [ ! -f "$IMG_PATH" ]; then
  error "File not found: $IMG_PATH"
  exit 1
fi

# --------- Validate extension ----------
case "$(printf '%s' "$IMG_PATH" | tr '[:upper:]' '[:lower:]')" in
  *.jpg|*.jpeg) : ;;
  *)
    error "Only .jpg or .jpeg files are allowed."
    exit 1
    ;;
esac

# --------- Validate MIME type ----------
MIME_TYPE="$(file -b --mime-type -- "$IMG_PATH" || true)"
if [ "$MIME_TYPE" != "image/jpeg" ]; then
  error "Input is not JPEG (detected: $MIME_TYPE). Only JPEG is allowed."
  exit 1
fi

# --------- Validate aspect ratio (16:9 within small tolerance) ----------
# Uses ImageMagick identify to fetch width/height
set +e
WH="$(identify -format "%w %h" -- "$IMG_PATH" 2>/dev/null)"
RC=$?
set -e
if [ $RC -ne 0 ] || [ -z "$WH" ]; then
  error "Could not read image dimensions with 'identify'."
  exit 1
fi

WIDTH="$(printf "%s" "$WH" | awk '{print $1}')"
HEIGHT="$(printf "%s" "$WH" | awk '{print $2}')"

# Check |(W/H) - (16/9)| <= 0.01
is_16by9="$(awk -v w="$WIDTH" -v h="$HEIGHT" 'BEGIN{
  if (h==0) { exit 1 }
  ratio=w/h; target=16/9; diff=(ratio>target)?ratio-target:target-ratio;
  if (diff <= 0.01) { print "yes" } else { print "no" }
}')"

if [ "$is_16by9" != "yes" ]; then
  error "Aspect ratio check failed. Detected ${WIDTH}×${HEIGHT} (~$(awk -v w="$WIDTH" -v h="$HEIGHT" 'BEGIN{printf "%.3f", w/h}') : 1). Required ~16:9."
  warn  "Tip: crop or resize to 16:9 (e.g., 1920x1080, 2560x1440, 3840x2160) then retry."
  exit 1
fi

info "Image OK: JPEG • ${WIDTH}×${HEIGHT} (≈16:9)"

# --------- Prepare destination & backup ----------
if [ ! -d "$TARGET_DIR" ]; then
  error "Target directory not found: $TARGET_DIR"
  exit 1
fi

TS="$(date +%Y%m%d-%H%M%S)"
if [ -f "$TARGET_FILE" ]; then
  BKP="${TARGET_FILE}.bak-${TS}"
  cp -p -- "$TARGET_FILE" "$BKP"
  info "Backup created: $BKP"
else
  warn "No existing $TARGET_FILE found — continuing."
fi

# --------- Install the image ----------
# We copy and then rename to exact required name (login-blurred)
TMP="${TARGET_DIR}/.login-blurred.${TS}.jpg"
cp -f -- "$IMG_PATH" "$TMP"

# Normalize permissions: root:root, 0644
chown root:root -- "$TMP"
chmod 0644 -- "$TMP"

# Move atomically into place
mv -f -- "$TMP" "$TARGET_FILE"

# --------- Finish ----------
success "Lock screen wallpaper replaced!"
printf "%s%sDone:%s %s → %s%s\n" "$C_BOLD" "$C_GREEN" "$C_RESET" "$IMG_PATH" "$TARGET_FILE" "$C_RESET"

cat <<EOF

${C_CYAN}Notes:${C_RESET}
• You may need to log out or reboot to see changes on the lock screen.
• File kept at: ${C_BOLD}$TARGET_FILE${C_RESET}
• Backup (if any): ${C_BOLD}${TARGET_FILE}.bak-${TS}${C_RESET}

${C_MAGENTA}${C_BOLD}Enjoy your fresh lock screen! ✨${C_RESET}
EOF
