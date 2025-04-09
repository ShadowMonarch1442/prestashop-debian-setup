#!/bin/bash

set -e

echo "==> Tambahkan DVD Debian (1 sampai 3)..."

for i in 1 2 3; do
    echo ""
    echo "==> Masukkan DVD Debian ke-$i, lalu tekan [ENTER]..."
    read

    echo "==> Mengecek DVD di /media/cdrom..."
    mount_point=$(find /media/ -maxdepth 1 -type d -name "cdrom*" | head -n 1)

    if [[ -z "$mount_point" ]]; then
        echo "✗ DVD gagal dimount. Pastikan disc dimasukkan dan dikenali sistem."
        exit 1
    fi

    echo "✓ DVD berhasil dimount."

    # Get DVD ID
    dvd_id=$(dd if="$mount_point/.disk/info" bs=1 count=512 2>/dev/null | md5sum | cut -d' ' -f1)
    echo "✓ DVD ke-$i terdeteksi dengan ID: $dvd_id"

    # Tambahkan repo dari DVD ke sources.list.d menggunakan apt-cdrom
    apt-cdrom -d "$mount_point" add -m -a
done

echo ""
echo "==> Semua DVD selesai ditambahkan. Repository sudah otomatis diperbarui oleh apt-cdrom."
echo ""

###############################
# Mulai instalasi PrestaShop #
###############################

echo "==> Memulai instalasi PrestaShop dan dependensi..."

# Install LAMP stack & pendukung
apt install -y apache2 mariadb-server php php-mysql libapache2-mod-php php-xml php-curl php-intl php-zip php-gd php-mbstring unzip wget

# Aktifkan modul rewrite Apache
a2enmod rewrite
systemctl restart apache2

# Setup database PrestaShop
echo "==> Membuat database dan user untuk PrestaShop..."
DB_NAME="prestashop_db"
DB_USER="shadow"
DB_PASS="1234"

mysql -e "CREATE DATABASE ${DB_NAME} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

echo "✓ Database berhasil dibuat."

# Download dan ekstrak PrestaShop
echo "==> Mendownload PrestaShop versi terbaru..."
cd /tmp
wget https://download.prestashop.com/download/releases/prestashop_1.7.8.10.zip -O prestashop.zip
unzip prestashop.zip -d prestashop

# Pindahkan ke direktori web
echo "==> Menyalin file PrestaShop ke /var/www/html/prestashop..."
rm -rf /var/www/html/prestashop
mkdir -p /var/www/html/prestashop
cp -r prestashop/* /var/www/html/prestashop/

# Ubah kepemilikan dan permission
chown -R www-data:www-data /var/www/html/prestashop
chmod -R 755 /var/www/html/prestashop

echo ""
echo "✓ PrestaShop berhasil dipasang."
echo ""
echo "==> Instalasi selesai!"
echo "Buka browser dan akses: http://<ip-server>/prestashop"
echo "Ikuti wizard instalasi, dan gunakan:"
echo "- DB Name : ${DB_NAME}"
echo "- DB User : ${DB_USER}"
echo "- DB Pass : ${DB_PASS}"
echo ""
echo "Setelah instalasi, hapus folder /install dan ubah nama folder /admin demi keamanan."
