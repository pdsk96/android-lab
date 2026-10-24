#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq
sudo apt-get install -y -qq openjdk-17-jdk openjdk-21-jdk unzip wget curl git python3-pip mono-devel mono-utils 2>&1 | tail -2

# Android SDK
export ANDROID_HOME=$HOME/android-sdk
mkdir -p $ANDROID_HOME/cmdline-tools
cd /tmp
wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline.zip
rm -rf $ANDROID_HOME/cmdline-tools/latest
unzip -q -o cmdline.zip -d $ANDROID_HOME/cmdline-tools
mv $ANDROID_HOME/cmdline-tools/cmdline-tools $ANDROID_HOME/cmdline-tools/latest
export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$PATH
yes | sdkmanager --licenses >/dev/null 2>&1 || true
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" >/dev/null 2>&1

# apktool
wget -q https://github.com/iBotPeaches/Apktool/releases/download/v2.9.3/apktool_2.9.3.jar -O /tmp/apktool.jar
sudo mv /tmp/apktool.jar /usr/local/bin/apktool.jar
printf '#!/bin/sh\nexec java -jar /usr/local/bin/apktool.jar "$@"\n' | sudo tee /usr/local/bin/apktool >/dev/null
sudo chmod +x /usr/local/bin/apktool

# jadx
wget -q https://github.com/skylot/jadx/releases/download/v1.5.0/jadx-1.5.0.zip -O /tmp/jadx.zip
rm -rf /opt/jadx
sudo mkdir -p /opt/jadx
sudo unzip -q -o /tmp/jadx.zip -d /opt/jadx
sudo ln -sf /opt/jadx/bin/jadx /usr/local/bin/jadx

# ghidra
wget -q https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_12.1.4_build/ghidra_12.1.4_PUBLIC_20260921.zip -O /tmp/ghidra.zip
rm -rf /opt/ghidra
sudo mkdir -p /opt/ghidra
sudo unzip -q /tmp/ghidra.zip -d /opt/ghidra

# python modules
pip install lz4 pyelftools xxhash setuptools 2>&1 | tail -1
cd /tmp && rm -rf pyxamstore && git clone https://github.com/jakev/pyxamstore.git 2>&1 | tail -1
cd /tmp/pyxamstore && python3 setup.py install 2>&1 | tail -1

# env
cat > ~/.android_env <<ENV
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export ANDROID_HOME=\$HOME/android-sdk
export PATH=\$JAVA_HOME/bin:\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$ANDROID_HOME/build-tools/34.0.0:\$PATH
export GHIDRA_INSTALL_DIR=/opt/ghidra/ghidra_12.1.4_PUBLIC
ENV
grep -q android_env ~/.bashrc 2>/dev/null || echo 'source ~/.android_env' >> ~/.bashrc

echo "SETUP_DONE"
