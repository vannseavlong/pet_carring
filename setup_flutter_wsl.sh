#!/usr/bin/env bash
# Flutter + Android SDK setup for WSL2 Ubuntu 22.04
# Run: bash setup_flutter_wsl.sh
set -e

FLUTTER_VERSION="3.32.2"
ANDROID_CMDTOOLS_VERSION="11076708"
INSTALL_DIR="$HOME/development"
ANDROID_HOME="$HOME/Android/Sdk"

echo "=========================================="
echo " Flutter WSL2 Setup Script"
echo "=========================================="

# ── 1. System packages ──────────────────────────────────────────────────────
echo ""
echo "[1/6] Installing system packages..."
sudo apt-get update -q
sudo apt --fix-broken install -y || true
sudo apt-get install -y \
  openjdk-17-jdk-headless \
  wget unzip curl git \
  libglu1-mesa \
  clang cmake ninja-build pkg-config
echo "  ✓ System packages installed"

# ── 2. Flutter SDK ──────────────────────────────────────────────────────────
echo ""
echo "[2/6] Downloading Flutter $FLUTTER_VERSION..."
mkdir -p "$INSTALL_DIR"
if [ ! -d "$INSTALL_DIR/flutter" ]; then
  wget -q --show-progress \
    "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    -O /tmp/flutter.tar.xz
  echo "  Extracting..."
  tar -xJf /tmp/flutter.tar.xz -C "$INSTALL_DIR"
  rm /tmp/flutter.tar.xz
  echo "  ✓ Flutter extracted to $INSTALL_DIR/flutter"
else
  echo "  ✓ Flutter already exists at $INSTALL_DIR/flutter, skipping"
fi

# ── 3. Android SDK cmdline-tools ────────────────────────────────────────────
echo ""
echo "[3/6] Downloading Android cmdline-tools..."
mkdir -p "$ANDROID_HOME/cmdline-tools"
if [ ! -d "$ANDROID_HOME/cmdline-tools/latest" ]; then
  wget -q --show-progress \
    "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMDTOOLS_VERSION}_latest.zip" \
    -O /tmp/cmdtools.zip
  echo "  Extracting..."
  unzip -q /tmp/cmdtools.zip -d /tmp/cmdtools_tmp
  mv /tmp/cmdtools_tmp/cmdline-tools "$ANDROID_HOME/cmdline-tools/latest"
  rm -rf /tmp/cmdtools.zip /tmp/cmdtools_tmp
  echo "  ✓ Android cmdline-tools installed"
else
  echo "  ✓ Android cmdline-tools already exist, skipping"
fi

# ── 4. Add to PATH in .bashrc ────────────────────────────────────────────────
echo ""
echo "[4/6] Configuring PATH..."
BASHRC="$HOME/.bashrc"

add_if_missing() {
  grep -qF "$1" "$BASHRC" || echo "$1" >> "$BASHRC"
}

add_if_missing 'export ANDROID_HOME="$HOME/Android/Sdk"'
add_if_missing 'export PATH="$PATH:$HOME/development/flutter/bin"'
add_if_missing 'export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"'
add_if_missing 'export PATH="$PATH:$ANDROID_HOME/platform-tools"'
add_if_missing 'export PATH="$PATH:$ANDROID_HOME/build-tools/34.0.0"'
add_if_missing 'export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"'

# Apply for this session
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$PATH:$HOME/development/flutter/bin"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/build-tools/34.0.0"
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
echo "  ✓ PATH configured in ~/.bashrc"

# ── 5. Install Android SDK components ────────────────────────────────────────
echo ""
echo "[5/6] Installing Android SDK components (this takes a few minutes)..."
yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses > /dev/null 2>&1 || true
"$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" \
  "platform-tools" \
  "platforms;android-35" \
  "build-tools;34.0.0" \
  "sources;android-35"
echo "  ✓ Android SDK components installed"

# ── 6. Flutter doctor ────────────────────────────────────────────────────────
echo ""
echo "[6/6] Running flutter doctor..."
"$INSTALL_DIR/flutter/bin/flutter" doctor --android-licenses < /dev/null || true
"$INSTALL_DIR/flutter/bin/flutter" doctor

echo ""
echo "=========================================="
echo " Setup complete!"
echo "=========================================="
echo ""
echo "NEXT STEPS to connect your Android phone:"
echo ""
echo "  Option A — Wireless ADB (easiest, Android 11+):"
echo "    1. On phone: Settings → Developer Options → Wireless Debugging → Enable"
echo "    2. Tap 'Pair device with pairing code', note the IP:port and pairing code"
echo "    3. In this terminal (after 'source ~/.bashrc'):"
echo "       adb pair <ip>:<pairing-port>"
echo "       adb connect <ip>:<port>"
echo "       flutter devices"
echo ""
echo "  Option B — USB via Windows ADB bridge:"
echo "    1. Install ADB on Windows (Android Platform Tools)"
echo "    2. Plug in phone, run in Windows CMD:"
echo "       adb -a nodaemon server start"
echo "    3. In this WSL terminal:"
echo "       export ADB_SERVER_SOCKET=tcp:10.255.255.254:5037"
echo "       adb devices"
echo ""
echo "  Option C — USB via usbipd-win (full USB passthrough):"
echo "    1. Install usbipd-win on Windows: winget install usbipd"
echo "    2. In Windows PowerShell (admin): usbipd list"
echo "    3. usbipd bind --busid <BUSID>"
echo "    4. usbipd attach --wsl --busid <BUSID>"
echo "    5. In WSL: adb devices"
echo ""
echo "Then run the app:"
echo "  source ~/.bashrc"
echo "  cd $(pwd)"
echo "  flutter pub get"
echo "  flutter run"
