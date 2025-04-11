# Setting database
echo "==> Membuat database dan user untuk PrestaShop..."
DB_NAME="prestashop_db"
DB_USER="kelasasj"
DB_PASS="adminTKJ123"

mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS ${DB_NAME} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "✓ Database berhasil dikonfigurasi."