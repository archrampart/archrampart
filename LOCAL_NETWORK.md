# Local Network Access

The web application is now configured to be accessible over the local network.

---

## 🇹🇷 Turkish / 🇬🇧 English

This document is available in both Turkish and English. Scroll down for the English version.

---

## 🇹🇷 Türkçe

### Yapılan Değişiklikler

1. **Frontend**: `0.0.0.0` üzerinden dinliyor (tüm network interface'leri)
2. **Backend**: CORS ayarları tüm origin'lere izin verecek şekilde güncellendi
3. **API Client**: Dinamik olarak aynı hostname'i kullanarak backend'e bağlanıyor

### Kullanım

#### 1. Backend'i Başlatın

```bash
cd backend
source venv/bin/activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

#### 2. Frontend'i Başlatın

```bash
cd frontend
npm run dev
```

#### 3. IP Adresinizi Öğrenin

```bash
hostname -I
# veya
ip addr show
```

Örnek çıktı: `192.168.100.105`

#### 4. Erişim

Aynı lokal network'teki diğer cihazlardan:

- **Frontend**: `http://192.168.100.105:5173`
- **Backend API**: `http://192.168.100.105:8000`
- **API Dokümantasyonu**: `http://192.168.100.105:8000/docs`

### Önemli Notlar

1. **Firewall**: Port 5173 (frontend) ve 8000 (backend) portlarının açık olduğundan emin olun:
   ```bash
   # Ubuntu/Debian
   sudo ufw allow 5173
   sudo ufw allow 8000
   ```

2. **Backend Host**: Backend'i `--host 0.0.0.0` ile başlatmanız gerekiyor (varsayılan olarak zaten ayarlı)

3. **API URL**: Frontend otomatik olarak aynı IP adresini kullanarak backend'e bağlanır. Eğer backend farklı bir IP'de çalışıyorsa, environment variable kullanabilirsiniz:
   ```bash
   # Frontend dizininde .env dosyası oluşturun
   echo "VITE_API_URL=http://192.168.100.105:8000" > .env
   ```

### Docker ile Kullanım

Docker Compose ile çalıştırıyorsanız, `docker-compose.yml` dosyasında port mapping zaten yapılmış durumda. Sadece:

```bash
docker-compose up -d
```

Komutu ile başlatın ve aynı şekilde IP adresiniz üzerinden erişin.

### Güvenlik Uyarısı

⚠️ **Development Modu**: Bu yapılandırma development için uygundur. Production ortamında:

1. CORS ayarlarını sadece belirli domain'lere izin verecek şekilde sınırlandırın
2. HTTPS kullanın
3. Firewall kurallarını sıkılaştırın
4. Authentication ve authorization mekanizmalarını güçlendirin

---

## 🇬🇧 English

### Changes Made

1. **Frontend**: Listens on `0.0.0.0` (all network interfaces)
2. **Backend**: CORS settings updated to allow all origins
3. **API Client**: Dynamically uses the same hostname to connect to backend

### Usage

#### 1. Start Backend

```bash
cd backend
source venv/bin/activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

#### 2. Start Frontend

```bash
cd frontend
npm run dev
```

#### 3. Find Your IP Address

```bash
hostname -I
# or
ip addr show
```

Example output: `192.168.100.105`

#### 4. Access

From other devices on the same local network:

- **Frontend**: `http://192.168.100.105:5173`
- **Backend API**: `http://192.168.100.105:8000`
- **API Documentation**: `http://192.168.100.105:8000/docs`

### Important Notes

1. **Firewall**: Make sure ports 5173 (frontend) and 8000 (backend) are open:
   ```bash
   # Ubuntu/Debian
   sudo ufw allow 5173
   sudo ufw allow 8000
   ```

2. **Backend Host**: You need to start backend with `--host 0.0.0.0` (already set by default)

3. **API URL**: Frontend automatically uses the same IP address to connect to backend. If backend is running on a different IP, you can use an environment variable:
   ```bash
   # Create .env file in frontend directory
   echo "VITE_API_URL=http://192.168.100.105:8000" > .env
   ```

### Usage with Docker

If running with Docker Compose, port mapping is already configured in `docker-compose.yml`. Just:

```bash
docker-compose up -d
```

Start with this command and access via your IP address in the same way.

### Security Warning

⚠️ **Development Mode**: This configuration is suitable for development. In production environment:

1. Limit CORS settings to only allow specific domains
2. Use HTTPS
3. Tighten firewall rules
4. Strengthen authentication and authorization mechanisms
