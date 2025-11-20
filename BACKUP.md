# ArchRampart Audit Tool - Backup and Restore Guide

This documentation describes the complete backup and restore operations for ArchRampart Audit Tool.

---

## 🇹🇷 Turkish / 🇬🇧 English

This document is available in both Turkish and English. Scroll down for the English version.

---

## 🇹🇷 Türkçe

### 📦 Yedeklenen Bileşenler

Yedekleme scripti aşağıdaki bileşenleri yedekler:

1. **PostgreSQL Veritabanı**
   - Tüm tablolar, veriler ve ilişkiler
   - Custom format (.dump) ve SQL format (.sql)

2. **Upload Edilmiş Dosyalar**
   - `backend/uploads/` dizinindeki tüm dosyalar
   - Bulgu kanıtları, ekler, vb.

3. **Kod Deposu**
   - Tüm kaynak kod dosyaları
   - Git repository (varsa)
   - node_modules ve venv hariç

4. **Konfigürasyon Dosyaları**
   - `docker-compose.yml`
   - `.env` dosyaları
   - `config.py`, `package.json`, `requirements.txt`
   - Diğer önemli konfigürasyon dosyaları

5. **Scripts ve Dokümantasyon**
   - Tüm `.md`, `.txt`, `.sh` dosyaları
   - `backend/scripts/` dizini

### 🚀 Yedekleme İşlemi

#### Otomatik Yedekleme

```bash
# Basit kullanım
./backup.sh

# Özel yedekleme dizini ile
BACKUP_DIR=/path/to/backups ./backup.sh

# Özel veritabanı ayarları ile
DB_HOST=192.168.1.100 DB_PORT=5432 ./backup.sh
```

#### Yedekleme Çıktısı

Yedekleme işlemi sonunda şu yapı oluşturulur:

```
backups/
└── rampart_backup_20250119_143022/
    ├── backup_info.txt          # Yedekleme bilgileri
    ├── database_20250119_143022.dump  # Veritabanı (custom format)
    ├── database_20250119_143022.sql   # Veritabanı (SQL format)
    ├── uploads/                  # Upload edilmiş dosyalar
    ├── code/                     # Kod deposu
    ├── config/                   # Konfigürasyon dosyaları
    └── docs_scripts/             # Dokümantasyon ve scriptler
```

### 🔄 Geri Yükleme İşlemi

#### Otomatik Geri Yükleme

```bash
# İnteraktif geri yükleme
./restore.sh
```

Script size mevcut yedekleri listeler ve seçim yapmanızı ister.

#### Manuel Geri Yükleme

**1. Veritabanı Geri Yükleme**

Docker ile:
```bash
# Custom format (.dump)
docker cp backups/rampart_backup_XXX/database_XXX.dump container_name:/tmp/restore.dump
docker exec container_name pg_restore -U archrampart -d archrampart_audit --clean --if-exists /tmp/restore.dump

# SQL format
docker cp backups/rampart_backup_XXX/database_XXX.sql container_name:/tmp/restore.sql
docker exec -i container_name psql -U archrampart -d archrampart_audit < /tmp/restore.sql
```

Doğrudan PostgreSQL:
```bash
# Custom format
pg_restore -h localhost -U archrampart -d archrampart_audit --clean --if-exists backups/.../database_XXX.dump

# SQL format
psql -h localhost -U archrampart -d archrampart_audit < backups/.../database_XXX.sql
```

**2. Upload Dosyaları Geri Yükleme**

```bash
cp -r backups/rampart_backup_XXX/uploads/* backend/uploads/
```

**3. Kod Dosyaları Geri Yükleme**

```bash
cp -r backups/rampart_backup_XXX/code/* ./
```

**4. Konfigürasyon Dosyaları Geri Yükleme**

```bash
# Dikkatli olun - mevcut ayarları değiştirebilir
cp -r backups/rampart_backup_XXX/config/* ./
```

### ⏰ Zamanlanmış Yedekleme (Cron)

Düzenli otomatik yedekleme için cron job ekleyin:

```bash
# Crontab'ı düzenle
crontab -e

# Her gün saat 02:00'de yedekleme yap
0 2 * * * cd /home/rampart/rampart && ./backup.sh >> /var/log/rampart_backup.log 2>&1

# Her hafta Pazar günü saat 03:00'de yedekleme yap
0 3 * * 0 cd /home/rampart/rampart && ./backup.sh >> /var/log/rampart_backup.log 2>&1
```

### 🗑️ Eski Yedekleri Temizleme

Eski yedekleri otomatik temizlemek için:

```bash
# 30 günden eski yedekleri sil
find ./backups -type d -name "rampart_backup_*" -mtime +30 -exec rm -rf {} \;
```

Veya cron job ile:

```bash
# Her gün eski yedekleri temizle (30 günden eski)
0 3 * * * find /home/rampart/rampart/backups -type d -name "rampart_backup_*" -mtime +30 -exec rm -rf {} \;
```

### 📤 Uzak Sunucuya Yedekleme

**SCP ile:**
```bash
# Yedekleme yap
./backup.sh

# Uzak sunucuya kopyala
scp -r backups/rampart_backup_XXX user@remote-server:/path/to/backups/
```

**Rsync ile:**
```bash
# Yedekleme yap
./backup.sh

# Uzak sunucuya senkronize et
rsync -avz backups/rampart_backup_XXX user@remote-server:/path/to/backups/
```

### 🔐 Güvenlik Notları

1. **.env Dosyaları**: Hassas bilgiler (şifreler, API anahtarları) içerir. Yedekleri güvenli bir yerde saklayın.
2. **Yedek Şifreleme**: Hassas veriler için yedekleri şifreleyin:
   ```bash
   tar czf - backups/rampart_backup_XXX | gpg -c > backup_encrypted.tar.gz.gpg
   ```
3. **Erişim Kontrolü**: Yedek dosyalarına erişimi kısıtlayın:
   ```bash
   chmod 700 backups/
   chmod 600 backups/*/database_*.dump
   ```

### ❓ Sık Sorulan Sorular

**S: Yedekleme ne kadar sürer?**  
C: Veri miktarına bağlı olarak 1-5 dakika arası.

**S: Yedekleme sırasında sistem çalışmaya devam edebilir mi?**  
C: Evet, yedekleme işlemi sistemin çalışmasını engellemez.

**S: Veritabanı yedeği alınırken veri kaybı olur mu?**  
C: Hayır, PostgreSQL'in transaction mekanizması sayesinde veri kaybı olmaz.

---

## 🇬🇧 English

### 📦 Backed Up Components

The backup script backs up the following components:

1. **PostgreSQL Database**
   - All tables, data, and relationships
   - Custom format (.dump) and SQL format (.sql)

2. **Uploaded Files**
   - All files in `backend/uploads/` directory
   - Finding evidence, attachments, etc.

3. **Code Repository**
   - All source code files
   - Git repository (if exists)
   - Excluding node_modules and venv

4. **Configuration Files**
   - `docker-compose.yml`
   - `.env` files
   - `config.py`, `package.json`, `requirements.txt`
   - Other important configuration files

5. **Scripts and Documentation**
   - All `.md`, `.txt`, `.sh` files
   - `backend/scripts/` directory

### 🚀 Backup Process

#### Automated Backup

```bash
# Simple usage
./backup.sh

# With custom backup directory
BACKUP_DIR=/path/to/backups ./backup.sh

# With custom database settings
DB_HOST=192.168.1.100 DB_PORT=5432 ./backup.sh
```

#### Backup Output

After backup process, the following structure is created:

```
backups/
└── rampart_backup_20250119_143022/
    ├── backup_info.txt          # Backup information
    ├── database_20250119_143022.dump  # Database (custom format)
    ├── database_20250119_143022.sql   # Database (SQL format)
    ├── uploads/                  # Uploaded files
    ├── code/                     # Code repository
    ├── config/                   # Configuration files
    └── docs_scripts/             # Documentation and scripts
```

### 🔄 Restore Process

#### Automated Restore

```bash
# Interactive restore
./restore.sh
```

The script lists available backups and asks you to make a selection.

#### Manual Restore

**1. Database Restore**

With Docker:
```bash
# Custom format (.dump)
docker cp backups/rampart_backup_XXX/database_XXX.dump container_name:/tmp/restore.dump
docker exec container_name pg_restore -U archrampart -d archrampart_audit --clean --if-exists /tmp/restore.dump

# SQL format
docker cp backups/rampart_backup_XXX/database_XXX.sql container_name:/tmp/restore.sql
docker exec -i container_name psql -U archrampart -d archrampart_audit < /tmp/restore.sql
```

Direct PostgreSQL:
```bash
# Custom format
pg_restore -h localhost -U archrampart -d archrampart_audit --clean --if-exists backups/.../database_XXX.dump

# SQL format
psql -h localhost -U archrampart -d archrampart_audit < backups/.../database_XXX.sql
```

**2. Upload Files Restore**

```bash
cp -r backups/rampart_backup_XXX/uploads/* backend/uploads/
```

**3. Code Files Restore**

```bash
cp -r backups/rampart_backup_XXX/code/* ./
```

**4. Configuration Files Restore**

```bash
# Be careful - may change existing settings
cp -r backups/rampart_backup_XXX/config/* ./
```

### ⏰ Scheduled Backup (Cron)

Add a cron job for regular automated backups:

```bash
# Edit crontab
crontab -e

# Backup daily at 02:00
0 2 * * * cd /home/rampart/rampart && ./backup.sh >> /var/log/rampart_backup.log 2>&1

# Backup weekly on Sunday at 03:00
0 3 * * 0 cd /home/rampart/rampart && ./backup.sh >> /var/log/rampart_backup.log 2>&1
```

### 🗑️ Cleaning Old Backups

To automatically clean old backups:

```bash
# Delete backups older than 30 days
find ./backups -type d -name "rampart_backup_*" -mtime +30 -exec rm -rf {} \;
```

Or with cron job:

```bash
# Clean old backups daily (older than 30 days)
0 3 * * * find /home/rampart/rampart/backups -type d -name "rampart_backup_*" -mtime +30 -exec rm -rf {} \;
```

### 📤 Backup to Remote Server

**Using SCP:**
```bash
# Create backup
./backup.sh

# Copy to remote server
scp -r backups/rampart_backup_XXX user@remote-server:/path/to/backups/
```

**Using Rsync:**
```bash
# Create backup
./backup.sh

# Sync to remote server
rsync -avz backups/rampart_backup_XXX user@remote-server:/path/to/backups/
```

**Automated Remote Backup Script:**

```bash
#!/bin/bash
# remote_backup.sh

# Local backup
./backup.sh

# Find latest backup
LATEST_BACKUP=$(ls -td backups/rampart_backup_* | head -1)

# Copy to remote server
rsync -avz "$LATEST_BACKUP" user@remote-server:/path/to/backups/

echo "Backup and remote copy completed: $LATEST_BACKUP"
```

### 🔐 Security Notes

1. **.env Files**: Contain sensitive information (passwords, API keys). Store backups securely.
2. **Backup Encryption**: Encrypt backups for sensitive data:
   ```bash
   tar czf - backups/rampart_backup_XXX | gpg -c > backup_encrypted.tar.gz.gpg
   ```
3. **Access Control**: Restrict access to backup files:
   ```bash
   chmod 700 backups/
   chmod 600 backups/*/database_*.dump
   ```
4. **Backup Verification**: Check backup integrity:
   ```bash
   # After backup
   tar -tzf backups/rampart_backup_XXX/code/repository_XXX.tar.gz > /dev/null && echo "Backup valid"
   ```

### 📊 Backup Size

Typical backup size:
- Database: 1-100 MB (depending on data amount)
- Upload files: Variable (depending on usage)
- Code: 10-50 MB
- Total: Usually 50-200 MB

### ❓ Frequently Asked Questions

**Q: How long does backup take?**  
A: 1-5 minutes depending on data amount.

**Q: Can the system continue running during backup?**  
A: Yes, the backup process does not prevent the system from running.

**Q: Will there be data loss when backing up the database?**  
A: No, PostgreSQL's transaction mechanism prevents data loss.

**Q: Can I move backups to a different server?**  
A: Yes, backups are portable and can be restored on a different server.

**Q: Can I do partial restore?**  
A: Yes, with restore.sh script you can restore only the components you want.

### 🆘 Troubleshooting

**Backup fails:**
- Check database connection
- Check disk space: `df -h`
- Check permissions: `ls -la backup.sh`

**Restore fails:**
- Check database connection
- Check backup file integrity
- Review log files

**Backup size too large:**
- Clean old upload files
- Clean old log records in database
- Exclude unnecessary files from backup
