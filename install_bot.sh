#!/bin/bash

# Update dan install dependensi
sudo apt update && sudo apt upgrade -y
sudo apt install python3 python3-pip python3-venv -y

# Buat direktori untuk bot
mkdir -p ~/xnew/Bot
cd ~/xnew/Bot

# Clone repositori
git clone https://github.com/ryankputra/bot2fa.git

# Masuk ke direktori bot
cd bot2fa

# Buat virtual environment
python3 -m venv botenv

# Aktifkan virtual environment
source botenv/bin/activate

# Install requirements
pip install -r requirements.txt

# Buat file service untuk systemd
cat <<EOF | sudo tee /etc/systemd/system/telegram-bot.service
[Unit]
Description=Telegram 2FA Bot Service
After=network.target

[Service]
User=botuser
WorkingDirectory=/home/botuser/xnew/Bot/bot2fa
ExecStart=/home/botuser/xnew/Bot/botenv/bin/python /home/botuser/xnew/Bot/bot2fa/2fa.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd dan start service
sudo systemctl daemon-reload
sudo systemctl start telegram-bot.service
sudo systemctl enable telegram-bot.service

echo "Instalasi selesai. Bot Telegram 2FA sudah berjalan."
