#!/bin/bash
set -e  # Stop kalau ada error

echo "==> Tambahkan DVD Debian (1 sampai 3)..."
for i in 1 2 3; do
  echo "==> Masukkan DVD Debian ke-$i, lalu tekan [ENTER]..."
  read
  apt-cdrom add -m -d /media/cdrom
done

echo "==> Update repository..."
apt update

echo "==> Install Apache2 dan MariaDB..."
read -p "Masukkan DVD Debian 1, lalu tekan [ENTER]..."
apt install -y apache2 mariadb-server

echo "==> Install PHP dan modulnya..."
read -p "Masukkan DVD Debian 2, lalu tekan [ENTER]..."
apt install -y php php-gd php-xml php-mbstring php-zip php-mysql php-curl php-intl

echo "==> Install wget, zip, dan unzip..."
read -p "Masukkan DVD Debian 3, lalu tekan [ENTER]..."
apt install -y wget zip unzip

echo "==> Download PrestaShop..."
wget https://github.com/PrestaShop/PrestaShop/releases/download/8.2.0/prestashop_8.2.0.zip -P /var/www

echo "==> Ekstrak dan pindahkan PrestaShop..."
cd /var/www
unzip -o prestashop_8.2.0.zip
mv prestashop.zip html/
cd html
unzip -o prestashop.zip -d prestashop

echo "==> Konfigurasi database..."
mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS prestashop_db;
CREATE USER IF NOT EXISTS 'shadow'@'localhost' IDENTIFIED BY '1234';
GRANT ALL PRIVILEGES ON prestashop_db.* TO 'shadow'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "✅ Setup selesai! Akses via browser di http://<ip-server>/prestashop"
