#!/bin/bash

# Script Aman Setup PrestaShop di Debian 10
# Dilengkapi loop untuk memastikan semua paket terinstall dengan benar

check_cdrom_mount() {
    echo "==> Mengecek DVD di /media/cdrom..."
    if mount /dev/sr0 /media/cdrom 2>/dev/null; then
        echo "✓ DVD berhasil dimount."
        return 0
    else
        echo "✗ DVD tidak terdeteksi. Pastikan DVD benar dan tekan ENTER untuk coba lagi."
        read -p "Tekan ENTER setelah memasukkan DVD yang benar..."
        return 1
    fi
}

echo "==> Tambahkan DVD Debian (1 sampai 3)..."
for i in 1 2 3; do
    echo "==> Masukkan DVD Debian ke-$i, lalu tekan [ENTER]..."
    while ! check_cdrom_mount; do
        :
    done
    apt-cdrom add -m
done

echo "==> Update repository..."
apt update

# Daftar paket penting
PACKAGES="apache2 mariadb-server php php-gd php-xml php-mbstring php-zip php-mysql php-curl php-intl wget zip unzip"

# Loop install sampai semua paket selesai
for package in $PACKAGES; do
    until dpkg -s $package &>/dev/null; do
        echo "==> Menginstall $package ..."
        apt install -y $package
    done
    echo "✓ $package sudah terinstall."
done

echo "==> Download PrestaShop 8.2.0..."
wget https://github.com/PrestaShop/PrestaShop/releases/download/8.2.0/prestashop_8.2.0.zip -P /var/www

echo "==> Ekstrak file PrestaShop..."
cd /var/www
unzip -o prestashop_8.2.0.zip
mv prestashop.zip html/
cd html
unzip -o prestashop.zip -d prestashop

echo "==> Konfigurasi database MySQL..."
mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE IF NOT
