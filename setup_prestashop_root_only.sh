#!/bin/bash

echo "==> Tambahkan DVD Debian (1 sampai 3)..."

# Buat mount point jika belum ada
mkdir -p /media/cdrom

# Fungsi untuk mount dan tambah DVD
tambah_dvd() {
  echo "==> Masukkan DVD Debian ke-$1, lalu tekan [ENTER]..."
  read -r
  echo "==> Mounting DVD ke-$1..."
  mount /dev/sr0 /media/cdrom

  echo "==> Menambahkan DVD ke daftar APT..."
  apt-cdrom add -d /media/cdrom

  echo "==> Unmount DVD ke-$1..."
  umount /media/cdrom
}

# Tambahkan ketiga DVD
tambah_dvd 1
tambah_dvd 2
tambah_dvd 3

echo "==> Update dan install dependensi..."
apt update
apt install -y apache2 mariadb-server php php-gd php-xml php-mbstring php-zip php-mysql php-curl php-intl wget zip unzip

echo "==> Download PrestaShop 8.2.0..."
wget https://github.com/PrestaShop/PrestaShop/releases/download/8.2.0/prestashop_8.2.0.zip -P /var/www

echo "==> Ekstrak file PrestaShop..."
cd /var/www
unzip prestashop_8.2.0.zip
mv prestashop.zip html/
cd html
unzip prestashop.zip -d prestashop

echo "==> Konfigurasi database MySQL..."
mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS prestashop_db;
CREATE USER IF NOT EXISTS 'shadow'@'localhost' IDENTIFIED BY '1234';
GRANT ALL PRIVILEGES ON prestashop_db.* TO 'shadow'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "==> Setup selesai! Akses PrestaShop via browser di http://<ip-server>/prestashop"
echo "==> Jangan lupa hapus folder /install dan ganti nama folder /admin setelah instalasi selesai via browser."
