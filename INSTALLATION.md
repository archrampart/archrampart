# ArchRampart Audit Tool - Installation Guide

This document describes how to run the application step by step.

---

## 🇹🇷 Turkish / 🇬🇧 English

This document is available in both Turkish and English. Scroll down for the English version.

---

## 🇹🇷 Türkçe

### Gereksinimler

- Python 3.11 veya üzeri
- Node.js 20 veya üzeri
- PostgreSQL 15 veya üzeri
- pip (Python paket yöneticisi)
- npm (Node.js paket yöneticisi)

### Yöntem 1: Manuel Kurulum (Geliştirme için önerilen)

#### 1. PostgreSQL Veritabanını Hazırlayın

```bash
# PostgreSQL'e bağlanın
sudo -u postgres psql

# Veritabanı ve kullanıcı oluşturun
CREATE DATABASE archrampart_audit;
CREATE USER archrampart WITH PASSWORD 'archrampart_pass';
GRANT ALL PRIVILEGES ON DATABASE archrampart_audit TO archrampart;
\q
```

#### 2. Backend'i Kurun ve Çalıştırın

```bash
# Backend dizinine gidin
cd backend

# Python virtual environment oluşturun
python3 -m venv venv

# Virtual environment'ı aktif edin
# Linux/Mac:
source venv/bin/activate
# Windows:
# venv\Scripts\activate

# Bağımlılıkları yükleyin
pip install -r requirements.txt

# .env dosyası zaten oluşturulmuş olmalı, kontrol edin
# Gerekirse düzenleyin:
# DATABASE_URL=postgresql://archrampart:archrampart_pass@localhost:5432/archrampart_audit

# Backend'i çalıştırın
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Backend başarıyla çalışıyorsa şu adreste erişilebilir:
- API: http://localhost:8000
- API Dokümantasyonu: http://localhost:8000/docs

#### 3. İlk Admin Kullanıcısını Oluşturun

Yeni bir terminal açın ve:

```bash
cd backend
source venv/bin/activate  # Windows: venv\Scripts\activate

# Admin kullanıcısı oluşturma scriptini çalıştırın
python scripts/create_admin.py
```

Script size e-posta, şifre ve ad soracak. Bu bilgileri girin.

#### 4. Frontend'i Kurun ve Çalıştırın

Yeni bir terminal açın ve:

```bash
# Frontend dizinine gidin
cd frontend

# Bağımlılıkları yükleyin
npm install

# Frontend'i çalıştırın
npm run dev
```

Frontend başarıyla çalışıyorsa şu adreste erişilebilir:
- Web Uygulaması: http://localhost:5173

#### 5. Giriş Yapın

1. Tarayıcınızda http://localhost:5173 adresine gidin
2. Oluşturduğunuz admin kullanıcısının e-posta ve şifresi ile giriş yapın

### Yöntem 2: Docker ile Kurulum (Hızlı Başlangıç)

#### 1. Docker ve Docker Compose'u Yükleyin

Docker ve Docker Compose'un yüklü olduğundan emin olun:
```bash
docker --version
docker-compose --version
```

#### 2. Uygulamayı Başlatın

```bash
# Proje kök dizininde
docker-compose up -d
```

Bu komut:
- PostgreSQL veritabanını başlatır
- Backend'i başlatır
- Frontend'i başlatır

#### 3. Logları Kontrol Edin

```bash
# Tüm servislerin loglarını görüntüleyin
docker-compose logs -f

# Sadece backend logları
docker-compose logs -f backend

# Sadece frontend logları
docker-compose logs -f frontend
```

#### 4. Uygulamaya Erişin

- Frontend: http://localhost:5173
- Backend API: http://localhost:8000
- API Dokümantasyonu: http://localhost:8000/docs

**Varsayılan Admin Kullanıcı:**
- Email: `admin@archrampart.com`
- Password: `admin123`

#### 5. Servisleri Durdurma

```bash
# Servisleri durdurun (veriler korunur)
docker-compose stop

# Servisleri durdurun ve container'ları silin
docker-compose down

# Verilerle birlikte her şeyi silin
docker-compose down -v
```

### Sorun Giderme

#### Backend başlamıyor

1. PostgreSQL'in çalıştığından emin olun:
   ```bash
   sudo systemctl status postgresql
   ```

2. Veritabanı bağlantı bilgilerini kontrol edin (`backend/.env`)

3. Port 8000'in kullanımda olmadığından emin olun:
   ```bash
   lsof -i :8000
   ```

#### Frontend başlamıyor

1. Node.js versiyonunu kontrol edin:
   ```bash
   node --version  # 20 veya üzeri olmalı
   ```

2. Port 5173'in kullanımda olmadığından emin olun:
   ```bash
   lsof -i :5173
   ```

3. `node_modules` klasörünü silip yeniden yükleyin:
   ```bash
   rm -rf node_modules package-lock.json
   npm install
   ```

#### Veritabanı bağlantı hatası

1. PostgreSQL'in çalıştığından emin olun
2. Veritabanı ve kullanıcının oluşturulduğundan emin olun
3. `.env` dosyasındaki `DATABASE_URL` değerini kontrol edin

#### CORS hatası

Backend'deki `ALLOWED_ORIGINS` ayarını kontrol edin. Frontend'in çalıştığı port bu listede olmalı.

### Sonraki Adımlar

1. İlk organizasyonu oluşturun (Platform Admin olarak)
2. Organizasyon için kullanıcılar oluşturun
3. Projeler oluşturun
4. Denetim şablonları oluşturun
5. Denetimler ve bulgular ekleyin

---

## 🇬🇧 English

### Requirements

- Python 3.11 or higher
- Node.js 20 or higher
- PostgreSQL 15 or higher
- pip (Python package manager)
- npm (Node.js package manager)

### Method 1: Manual Installation (Recommended for development)

#### 1. Prepare PostgreSQL Database

```bash
# Connect to PostgreSQL
sudo -u postgres psql

# Create database and user
CREATE DATABASE archrampart_audit;
CREATE USER archrampart WITH PASSWORD 'archrampart_pass';
GRANT ALL PRIVILEGES ON DATABASE archrampart_audit TO archrampart;
\q
```

#### 2. Install and Run Backend

```bash
# Go to backend directory
cd backend

# Create Python virtual environment
python3 -m venv venv

# Activate virtual environment
# Linux/Mac:
source venv/bin/activate
# Windows:
# venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# .env file should already be created, check it
# Edit if necessary:
# DATABASE_URL=postgresql://archrampart:archrampart_pass@localhost:5432/archrampart_audit

# Run backend
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

If backend is running successfully, it can be accessed at:
- API: http://localhost:8000
- API Documentation: http://localhost:8000/docs

#### 3. Create First Admin User

Open a new terminal and:

```bash
cd backend
source venv/bin/activate  # Windows: venv\Scripts\activate

# Run admin user creation script
python scripts/create_admin.py
```

The script will ask you for email, password, and name. Enter these information.

#### 4. Install and Run Frontend

Open a new terminal and:

```bash
# Go to frontend directory
cd frontend

# Install dependencies
npm install

# Run frontend
npm run dev
```

If frontend is running successfully, it can be accessed at:
- Web Application: http://localhost:5173

#### 5. Log In

1. Go to http://localhost:5173 in your browser
2. Log in with the email and password of the admin user you created

### Method 2: Docker Installation (Quick Start)

#### 1. Install Docker and Docker Compose

Make sure Docker and Docker Compose are installed:
```bash
docker --version
docker-compose --version
```

#### 2. Start the Application

```bash
# In project root directory
docker-compose up -d
```

This command:
- Starts PostgreSQL database
- Starts Backend
- Starts Frontend

#### 3. Check Logs

```bash
# View logs of all services
docker-compose logs -f

# Only backend logs
docker-compose logs -f backend

# Only frontend logs
docker-compose logs -f frontend
```

#### 4. Access the Application

- Frontend: http://localhost:5173
- Backend API: http://localhost:8000
- API Documentation: http://localhost:8000/docs

**Default Admin User:**
- Email: `admin@archrampart.com`
- Password: `admin123`

#### 5. Stop Services

```bash
# Stop services (data is preserved)
docker-compose stop

# Stop services and remove containers
docker-compose down

# Remove everything including data
docker-compose down -v
```

### Troubleshooting

#### Backend not starting

1. Make sure PostgreSQL is running:
   ```bash
   sudo systemctl status postgresql
   ```

2. Check database connection information (`backend/.env`)

3. Make sure port 8000 is not in use:
   ```bash
   lsof -i :8000
   ```

#### Frontend not starting

1. Check Node.js version:
   ```bash
   node --version  # Should be 20 or higher
   ```

2. Make sure port 5173 is not in use:
   ```bash
   lsof -i :5173
   ```

3. Delete `node_modules` folder and reinstall:
   ```bash
   rm -rf node_modules package-lock.json
   npm install
   ```

#### Database connection error

1. Make sure PostgreSQL is running
2. Make sure database and user are created
3. Check `DATABASE_URL` value in `.env` file

#### CORS error

Check `ALLOWED_ORIGINS` setting in backend. The port where frontend is running should be in this list.

### Next Steps

1. Create first organization (as Platform Admin)
2. Create users for organization
3. Create projects
4. Create audit templates
5. Add audits and findings

### Help

If you encounter issues:
- Check API documentation: http://localhost:8000/docs
- Review log files
- Search in GitHub issues (if public repo)
