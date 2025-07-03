#!/bin/bash
# kodi_lcd_autoboot.sh
# 자동으로 Kodi를 XPT2046 LCD에 실행하도록 설정하는 스크립트 (Raspberry Pi OS Full 기준)

echo "[1/6] lightdm 비활성화 중..."
sudo systemctl disable lightdm

echo "[2/6] X 서버 관련 패키지 설치 확인..."
sudo apt update
sudo apt install --reinstall xserver-xorg xinit x11-xserver-utils -y

echo "[3/6] 사용자 xinitrc 설정..."
cat <<EOF > ~/.xinitrc
xset s off
xset -dpms
xset s noblank
export FRAMEBUFFER=/dev/fb1
exec kodi-standalone
EOF

echo "[4/6] 사용자 bash_profile 설정..."
cat <<EOF > ~/.bash_profile
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    startx
fi
EOF

echo "[5/6] Kodi 실행 테스트 권장: 'startx'를 수동으로 한 번 실행해보세요."

echo "[6/6] 설정 완료. 재부팅합니다..."
sleep 2
sudo reboot
