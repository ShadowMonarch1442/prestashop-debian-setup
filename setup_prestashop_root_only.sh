#!/bin/bash

# Setup PrestaShop di Debian 10 via DVD (3 Disk)
# Versi stabil dengan deteksi ID disc + retry apt install

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

get_disc_id() {
    apt-cdrom ident 2>/dev/null | grep "Identifying" | sed 's/.*\[\(.*\)\]/\1/'
}

echo "==> Tambahkan DVD Debian (1 sampai 3)..."
PREV_ID=""
for i in 1 2 3; do
    eject /dev/sr0
    echo "==> Masukkan DVD Debian ke-$i, lalu tekan [ENTER]..."
    read
    sleep 2

    while true; do
        if check_cdrom_mount; then
            CURRENT_ID=$(get_disc_id)
            if [ "$CURRENT_ID" != "$PREV_ID" ] && [ ! -z "$CURRENT_ID" ]; then
                echo "✓ DVD ke-$i terdeteksi dengan ID: $CURRENT_ID"
                PREV_ID="$CURRENT_ID"
                apt-cdrom add -m
                break
            else
                echo "✗ Disc masih sama atau gagal terbaca. Pastikan disc sudah diganti."
            fi
        fi
        echo "Coba lagi? Tekan ENTER setelah mengganti DVD..."
        read
        sleep 2
    done
done

echo "==> Semua DVD selesai ditambahkan. Melakukan update repository..."
apt update || { echo "✗ apt update gagal. Periksa DVD atau repository Anda."; exit 1; }

echo "==> Menginstall dependensi (Apache2, PHP, MariaDB)..."
INSTALL_PKGS="apache2 mariadb-server php php-gd php-xml php-mbstring php-zip php-mysql php-curl php-intl wget zip unzip"
MAX_RETRY=5
for ((i=1; i<=MAX_RETRY; i++)); do
    apt install -y $INSTALL_PKGS && break
    echo "✗ Install gagal, percobaan ke-$i/$MAX_RETRY. Masukkan DVD yang dibutuhkan lalu tekan ENTER..."
    read
    eject /dev/sr0
    sleep 2
done

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
