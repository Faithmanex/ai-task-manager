#!/bin/bash
# Vercel build: install Flutter SDK, build web app.
# See vercel.json / BLUEPRINT.md §6.
set -e

FLUTTER_VERSION="${FLUTTER_VERSION:-3.47.3}"
FLUTTER_DIR="/opt/flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
  curl -sL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" -o /tmp/flutter.tar.xz
  tar -xJf /tmp/flutter.tar.xz -C /opt
fi

git config --global --add safe.directory "$FLUTTER_DIR"
export PATH="$FLUTTER_DIR/bin:$PATH"

flutter --version
flutter pub get
flutter build web --release
