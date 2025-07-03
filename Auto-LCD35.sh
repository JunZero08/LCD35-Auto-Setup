#!/bin/bash
# LCD_setup.sh
# 자동 XPT2046 3.5" LCD + GUI + 터치 캘리브레이션 설치

set -e

echo "1/7 LCD 드라이버 설치 중..."
rm -rf ~/LCD-show
git clone https://github.com/goodtft/LCD-show.git ~/LCD-show
cd ~/LCD-show
chmod +x LCD35-show
sudo ./LCD35-show

echo "2/7 fb1 디바이스 확인..."
sleep 2
if [ ! -e /dev/fb1 ]; then
  echo "[오류] /dev/fb1 드라이버 미로드!"
  exit 1
fi

echo "3/7 X 설정 파일 생성..."
sudo tee /usr/share/X11/xorg.conf.d/99-fbturbo.conf > /dev/null <<EOF
Section "Device"
    Identifier "LCD"
    Driver "fbdev"
    Option "fbdev" "/dev/fb1"
EndSection
EOF

echo "4/7 framebuffer 우선순위 설정..."
sudo sed -i '/^framebuffer_priority=/d' /boot/config.txt
echo "framebuffer_priority=2" | sudo tee -a /boot/config.txt

echo "5/7 GUI(lightdm) 자동 실행 설정 확인..."
sudo systemctl enable lightdm
sudo systemctl restart lightdm || true

echo "6/7 터치 캘리브레이션 도구 설치..."
sudo apt update
sudo apt install -y xinput-calibrator

echo "7/7 터치 캘리브레이션 설정..."
CAL_CONF="/etc/X11/xorg.conf.d/99-calibration.conf"
sudo mkdir -p "$(dirname $CAL_CONF)"
sudo tee "$CAL_CONF" > /dev/null <<EOF
Section "InputClass"
    Identifier "calibration"
    MatchProduct "ADS7846 Touchscreen"
    Option "Calibration" "200 3900 3900 200"
    Option "SwapAxes" "1"
EndSection
EOF

echo
echo "✅ 완료되었습니다! 지금 데스크탑 GUI가 LCD에 출력되고 있을 겁니다."
echo "재부팅 후에도 자동 실행됩니다."
echo
echo "📌 시작하려면: startx 또는 lightdm 재시작"
