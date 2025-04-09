#!/bin/bash

set -e

echo "==> Memulai instalasi PrestaShop dan dependensi..."

# Daftar paket yang dibutuhkan
INSTALL_PKGS="apache2 mariadb-server php php-gd php-xml php-mbstring php-zip php-mysql php-curl php-intl wget zip unzip"
MAX_RETRY=5

# Install dengan retry jika minta DVD
for ((i=1; i<=MAX_RETRY; i++)); do
    if apt install -y $INSTALL_PKGS; then
        echo "✓ Semua paket berhasil diinstall."
        break
    else
        echo "✗ Gagal install (percobaan $i/$MAX_RETRY). Mungkin perlu ganti DVD."
        read -p "Masukkan DVD yang diperlukan lalu tekan ENTER untuk melanjutkan..."
        eject /dev/sr0
        sleep 2
    fi
done

# Aktifkan modul rewrite Apache
a2enmod rewrite
systemctl restart apache2

# Setting database
echo "==> Membuat database dan user untuk PrestaShop..."
DB_NAME="prestashop_db"
DB_USER="shadow"
DB_PASS="1234"

mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS ${DB_NAME} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "✓ Database berhasil dikonfigurasi."

# Download PrestaShop
echo "==> Mendownload PrestaShop versi 8.2.0..."
wget https://github.com/PrestaShop/PrestaShop/releases/download/8.2.0/prestashop_8.2.0.zip -O /var/www/prestashop_8.2.0.zip

# Ekstrak PrestaShop
echo "==> Mengekstrak PrestaShop..."
cd /var/www
unzip prestashop_8.2.0.zip
mv prestashop.zip html/
cd html
unzip prestashop.zip -d prestashop

# Atur izin
chown -R www-data:www-data /var/www/html/prestashop
chmod -R 755 /var/www/html/prestashop

# Info akhir
echo ""
echo "==> Instalasi selesai!"
echo "Silakan buka browser dan akses: http://<ip-server>/prestashop"
echo "Ikuti wizard instalasi, dan gunakan:"
echo "- DB Name : ${DB_NAME}"
echo "- DB User : ${DB_USER}"
echo "- DB Pass : ${DB_PASS}"
echo ""
echo "🧹 Setelah instalasi:"
echo "- Hapus folder /install"
echo "- Ganti nama folder /admin menjadi sesuatu yang unik"
