# ArchRampart Audit Tool - Docker Installation Guide

This document describes the Docker installation and usage of ArchRampart Audit Tool.

---

## 🇹🇷 Turkish / 🇬🇧 English

This document is available in both Turkish and English. Scroll down for the English version.

---

## 🇹🇷 Türkçe

### 🚀 Tek Komutla Başlatma

```bash
./docker-up.sh
```

Bu komut tüm sisteminizi otomatik olarak kurar ve başlatır.

### 📋 Gereksinimler

- Docker 20.10+
- Docker Compose 2.0+ (veya `docker compose` plugin)

### 🔧 Yapılandırma

#### Environment Variables (.env)

Proje kök dizininde `.env` dosyası oluşturarak ayarları özelleştirebilirsiniz:

```bash
# PostgreSQL Configuration
POSTGRES_USER=archrampart
POSTGRES_PASSWORD=archrampart_pass
POSTGRES_DB=archrampart_audit
POSTGRES_PORT=5432

# Backend Configuration
BACKEND_PORT=8000
SECRET_KEY=change-this-secret-key-in-production-use-a-long-random-string
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440
DEBUG=True
ALLOWED_ORIGINS=*

# File Upload
MAX_UPLOAD_SIZE=10485760

# i18n
DEFAULT_LANGUAGE=tr
SUPPORTED_LANGUAGES=tr,en

# Frontend Configuration
FRONTEND_PORT=5173
VITE_API_URL=http://localhost:8000

# Admin User (will be created on first startup)
ADMIN_EMAIL=admin@archrampart.com
ADMIN_PASSWORD=admin123
ADMIN_NAME=Platform Admin
```

### 🐳 Docker Compose Servisleri

#### 1. PostgreSQL (db)

- **Image**: postgres:15
- **Port**: 5432 (default)
- **Volume**: `postgres_data` (kalıcı veri depolama)
- **Health Check**: Aktif

#### 2. Backend

- **Port**: 8000 (default)
- **Auto-initialization**: 
  - Veritabanı tabloları oluşturulur
  - Migration'lar çalıştırılır
  - Varsayılan şablonlar oluşturulur
  - Admin kullanıcısı oluşturulur
- **Volume**: 
  - `./backend:/app` (kod dosyaları)
  - `./backend/uploads:/app/uploads` (upload edilmiş dosyalar)

#### 3. Frontend

- **Port**: 5173 (default)
- **Development Server**: Vite dev server
- **Volume**: 
  - `./frontend:/app` (kod dosyaları)
  - `/app/node_modules` (node modülleri, container içinde)

### 📝 Kullanım

#### Başlatma

```bash
# İlk kez başlatma (imajları oluşturur)
docker-compose up -d --build

# Veya basit başlatma
docker-compose up -d

# Veya script ile
./docker-up.sh
```

#### Durumu Kontrol Etme

```bash
# Tüm servislerin durumunu görüntüle
docker-compose ps

# Belirli bir servisin durumunu kontrol et
docker-compose ps backend
docker-compose ps frontend
docker-compose ps db
```

#### Loglar

```bash
# Tüm servislerin loglarını görüntüle
docker-compose logs -f

# Belirli bir servisin loglarını görüntüle
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f db

# Son N satırı görüntüle
docker-compose logs --tail=100 backend
```

#### Durdurma

```bash
# Servisleri durdur (container'ları silmez)
docker-compose stop

# Servisleri durdur ve container'ları sil
docker-compose down

# Servisleri durdur, container'ları sil ve volume'ları sil (dikkatli!)
docker-compose down -v
```

#### Yeniden Başlatma

```bash
# Tüm servisleri yeniden başlat
docker-compose restart

# Belirli bir servisi yeniden başlat
docker-compose restart backend

# Servisleri durdurup tekrar başlat
docker-compose down && docker-compose up -d
```

### 🔄 Veritabanı İşlemleri

#### Veritabanına Bağlanma

```bash
# Container içindeki PostgreSQL'e bağlan
docker-compose exec db psql -U archrampart -d archrampart_audit

# Dışarıdan bağlan (localhost:5432)
psql -h localhost -p 5432 -U archrampart -d archrampart_audit
```

#### Veritabanı Yedeği

```bash
# Yedek al
docker-compose exec db pg_dump -U archrampart archrampart_audit > backup.sql

# Yedeği geri yükle
docker-compose exec -T db psql -U archrampart archrampart_audit < backup.sql
```

#### Veritabanı Sıfırlama

```bash
# Dikkat: Tüm veriler silinir!
docker-compose down -v
docker-compose up -d
```

### 🛠️ Geliştirme

#### Kod Değişiklikleri

Docker Compose volume mapping sayesinde kod değişiklikleri anında yansır:

- **Backend**: `./backend:/app` - Değişiklikler anında görünür (reload mode)
- **Frontend**: `./frontend:/app` - Değişiklikler anında görünür (hot reload)

#### Yeni Paket Ekleme

**Backend:**

```bash
# Container içine gir
docker-compose exec backend bash

# Paket yükle
pip install package-name

# requirements.txt'i güncelle
pip freeze > requirements.txt

# Container'dan çık
exit

# Docker imajını yeniden oluştur
docker-compose build backend
docker-compose up -d backend
```

**Frontend:**

```bash
# Container içine gir
docker-compose exec frontend sh

# Paket yükle
npm install package-name

# package.json otomatik güncellenir
# Container'dan çık
exit

# Docker imajını yeniden oluştur
docker-compose build frontend
docker-compose up -d frontend
```

### 🏭 Production Deployment

Production ortamı için `docker-compose.prod.yml` kullanın:

```bash
# Production build
docker-compose -f docker-compose.prod.yml build

# Production'da başlat
docker-compose -f docker-compose.prod.yml up -d
```

#### Production Ayarları

- **Frontend**: Nginx ile serve edilir (optimize edilmiş build)
- **Backend**: Multiple workers ile çalışır (daha iyi performans)
- **Debug**: Kapalı
- **CORS**: Sadece belirtilen origin'ler (güvenlik)
- **HTTPS**: Nginx üzerinden SSL/TLS eklenebilir

#### Production .env Örneği

```bash
# Production için .env
POSTGRES_PASSWORD=secure-random-password-here
SECRET_KEY=very-long-random-secret-key-here
DEBUG=False
ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
ADMIN_EMAIL=admin@yourdomain.com
ADMIN_PASSWORD=secure-admin-password
```

### 🐛 Sorun Giderme

#### Servis Başlamıyor

```bash
# Logları kontrol et
docker-compose logs backend
docker-compose logs frontend
docker-compose logs db

# Container durumunu kontrol et
docker-compose ps

# Container'ı yeniden oluştur
docker-compose up -d --force-recreate backend
```

#### Port Çakışması

Port zaten kullanılıyorsa `.env` dosyasında port numaralarını değiştirin:

```bash
BACKEND_PORT=8001
FRONTEND_PORT=5174
POSTGRES_PORT=5433
```

#### Veritabanı Bağlantı Hatası

```bash
# Veritabanı servisinin durumunu kontrol et
docker-compose ps db

# Veritabanı loglarını kontrol et
docker-compose logs db

# Veritabanını yeniden başlat
docker-compose restart db

# Backend'i beklet ve tekrar başlat
docker-compose restart backend
```

#### İmajları Temizleme

```bash
# Kullanılmayan imajları sil
docker image prune -a

# Kullanılmayan container'ları sil
docker container prune

# Kullanılmayan volume'ları sil (dikkatli!)
docker volume prune

# Tümünü temizle (dikkatli!)
docker system prune -a
```

### 📊 Performans İzleme

```bash
# Container kaynak kullanımını görüntüle
docker stats

# Belirli container'ları izle
docker stats rampart_backend rampart_frontend rampart_db
```

### 🔐 Güvenlik Notları

1. **Production'da**:
   - `.env` dosyasındaki şifreleri güçlü yapın
   - `SECRET_KEY` değerini uzun ve rastgele yapın
   - `ALLOWED_ORIGINS` listesini sınırlayın
   - `DEBUG=False` yapın

2. **Volume Güvenliği**:
   - `postgres_data` volume'unu düzenli yedekleyin
   - `uploads` dizinini düzenli yedekleyin

3. **Network Güvenliği**:
   - Production'da sadece gerekli portları expose edin
   - Firewall kuralları ekleyin
   - HTTPS kullanın

---

## 🇬🇧 English

### 🚀 Single Command Startup

```bash
./docker-up.sh
```

This command automatically installs and starts your entire system.

### 📋 Requirements

- Docker 20.10+
- Docker Compose 2.0+ (or `docker compose` plugin)

### 🔧 Configuration

#### Environment Variables (.env)

You can customize settings by creating a `.env` file in the project root directory:

```bash
# PostgreSQL Configuration
POSTGRES_USER=archrampart
POSTGRES_PASSWORD=archrampart_pass
POSTGRES_DB=archrampart_audit
POSTGRES_PORT=5432

# Backend Configuration
BACKEND_PORT=8000
SECRET_KEY=change-this-secret-key-in-production-use-a-long-random-string
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440
DEBUG=True
ALLOWED_ORIGINS=*

# File Upload
MAX_UPLOAD_SIZE=10485760

# i18n
DEFAULT_LANGUAGE=tr
SUPPORTED_LANGUAGES=tr,en

# Frontend Configuration
FRONTEND_PORT=5173
VITE_API_URL=http://localhost:8000

# Admin User (will be created on first startup)
ADMIN_EMAIL=admin@archrampart.com
ADMIN_PASSWORD=admin123
ADMIN_NAME=Platform Admin
```

### 🐳 Docker Compose Services

#### 1. PostgreSQL (db)

- **Image**: postgres:15
- **Port**: 5432 (default)
- **Volume**: `postgres_data` (persistent data storage)
- **Health Check**: Active

#### 2. Backend

- **Port**: 8000 (default)
- **Auto-initialization**: 
  - Database tables are created
  - Migrations are run
  - Default templates are created
  - Admin user is created
- **Volume**: 
  - `./backend:/app` (code files)
  - `./backend/uploads:/app/uploads` (uploaded files)

#### 3. Frontend

- **Port**: 5173 (default)
- **Development Server**: Vite dev server
- **Volume**: 
  - `./frontend:/app` (code files)
  - `/app/node_modules` (node modules, inside container)

### 📝 Usage

#### Startup

```bash
# First time startup (builds images)
docker-compose up -d --build

# Or simple startup
docker-compose up -d

# Or with script
./docker-up.sh
```

#### Check Status

```bash
# View status of all services
docker-compose ps

# Check status of specific service
docker-compose ps backend
docker-compose ps frontend
docker-compose ps db
```

#### Logs

```bash
# View logs of all services
docker-compose logs -f

# View logs of specific service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f db

# View last N lines
docker-compose logs --tail=100 backend
```

#### Stop

```bash
# Stop services (does not remove containers)
docker-compose stop

# Stop services and remove containers
docker-compose down

# Stop services, remove containers and volumes (careful!)
docker-compose down -v
```

#### Restart

```bash
# Restart all services
docker-compose restart

# Restart specific service
docker-compose restart backend

# Stop and start again
docker-compose down && docker-compose up -d
```

### 🔄 Database Operations

#### Connect to Database

```bash
# Connect to PostgreSQL in container
docker-compose exec db psql -U archrampart -d archrampart_audit

# Connect from outside (localhost:5432)
psql -h localhost -p 5432 -U archrampart -d archrampart_audit
```

#### Database Backup

```bash
# Create backup
docker-compose exec db pg_dump -U archrampart archrampart_audit > backup.sql

# Restore backup
docker-compose exec -T db psql -U archrampart archrampart_audit < backup.sql
```

#### Database Reset

```bash
# Warning: All data will be deleted!
docker-compose down -v
docker-compose up -d
```

### 🛠️ Development

#### Code Changes

Thanks to Docker Compose volume mapping, code changes are reflected immediately:

- **Backend**: `./backend:/app` - Changes visible immediately (reload mode)
- **Frontend**: `./frontend:/app` - Changes visible immediately (hot reload)

#### Adding New Packages

**Backend:**

```bash
# Enter container
docker-compose exec backend bash

# Install package
pip install package-name

# Update requirements.txt
pip freeze > requirements.txt

# Exit container
exit

# Rebuild Docker image
docker-compose build backend
docker-compose up -d backend
```

**Frontend:**

```bash
# Enter container
docker-compose exec frontend sh

# Install package
npm install package-name

# package.json is automatically updated
# Exit container
exit

# Rebuild Docker image
docker-compose build frontend
docker-compose up -d frontend
```

### 🏭 Production Deployment

For production environment, use `docker-compose.prod.yml`:

```bash
# Production build
docker-compose -f docker-compose.prod.yml build

# Start in production
docker-compose -f docker-compose.prod.yml up -d
```

#### Production Settings

- **Frontend**: Served with Nginx (optimized build)
- **Backend**: Runs with multiple workers (better performance)
- **Debug**: Disabled
- **CORS**: Only specified origins (security)
- **HTTPS**: SSL/TLS can be added via Nginx

#### Production .env Example

```bash
# .env for production
POSTGRES_PASSWORD=secure-random-password-here
SECRET_KEY=very-long-random-secret-key-here
DEBUG=False
ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
ADMIN_EMAIL=admin@yourdomain.com
ADMIN_PASSWORD=secure-admin-password
```

### 🐛 Troubleshooting

#### Service Not Starting

```bash
# Check logs
docker-compose logs backend
docker-compose logs frontend
docker-compose logs db

# Check container status
docker-compose ps

# Recreate container
docker-compose up -d --force-recreate backend
```

#### Port Conflict

If port is already in use, change port numbers in `.env` file:

```bash
BACKEND_PORT=8001
FRONTEND_PORT=5174
POSTGRES_PORT=5433
```

#### Database Connection Error

```bash
# Check database service status
docker-compose ps db

# Check database logs
docker-compose logs db

# Restart database
docker-compose restart db

# Wait and restart backend
docker-compose restart backend
```

#### Cleaning Images

```bash
# Remove unused images
docker image prune -a

# Remove unused containers
docker container prune

# Remove unused volumes (careful!)
docker volume prune

# Clean everything (careful!)
docker system prune -a
```

### 📊 Performance Monitoring

```bash
# View container resource usage
docker stats

# Monitor specific containers
docker stats rampart_backend rampart_frontend rampart_db
```

### 🔐 Security Notes

1. **In Production**:
   - Make passwords in `.env` file strong
   - Make `SECRET_KEY` value long and random
   - Limit `ALLOWED_ORIGINS` list
   - Set `DEBUG=False`

2. **Volume Security**:
   - Regularly backup `postgres_data` volume
   - Regularly backup `uploads` directory

3. **Network Security**:
   - In production, only expose necessary ports
   - Add firewall rules
   - Use HTTPS

### 🆘 Help

If you encounter issues:
1. Check logs: `docker-compose logs -f`
2. Check container status: `docker-compose ps`
3. Review documentation: `TROUBLESHOOTING.md`
