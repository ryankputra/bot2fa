#!/bin/bash

# Pembukaan
clear
echo "============================================="
echo "          Selamat datang di RyyStore.v2      "
echo "        Instalasi Telegram 2FA Bot           "
echo "============================================="
echo ""
echo "Script ini akan menginstal dan menjalankan bot secara otomatis."
echo "Pastikan Menggunakan VPS yang Kompetible"
echo ""
sleep 2

# Update dan install dependensi
echo "Memperbarui sistem dan menginstal dependensi..."
sudo apt update && sudo apt upgrade -y
sudo apt install python3 python3-pip python3-venv -y

# Buat direktori untuk bot
echo "Mempersiapkan direktori bot..."
mkdir -p ~/xnew/Bot
cd ~/xnew/Bot

# Clone repositori
echo "Mengunduh kode bot dari repository..."
git clone https://github.com/ryankputra/bot2fa.git

# Masuk ke direktori bot
cd bot2fa

# Buat virtual environment
echo "Membuat virtual environment untuk bot..."
python3 -m venv botenv

# Aktifkan virtual environment
source botenv/bin/activate

# Install requirements
echo "Menginstal dependensi bot..."
pip install -r requirements.txt

# Buat file service untuk systemd
echo "Membuat file service untuk menjalankan bot secara otomatis..."
cat <<EOF | sudo tee /etc/systemd/system/telegram-bot.service
[Unit]
Description=Telegram 2FA Bot Service
After=network.target

[Service]
User=$USER
WorkingDirectory=$(pwd)
ExecStart=$(pwd)/botenv/bin/python $(pwd)/2fa.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd dan start service
echo "Mengaktifkan service bot..."
sudo systemctl daemon-reload
sudo systemctl start telegram-bot.service
sudo systemctl enable telegram-bot.service

echo ""
echo "============================================="
echo "         Instalasi selesai!                 "
echo "    Bot Telegram 2FA kini berjalan.         "
echo "       Terima kasih menggunakan RyyStore.v2 "
echo "============================================="
