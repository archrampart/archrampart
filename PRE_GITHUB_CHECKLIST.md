# GitHub'a Yüklemeden Önce Kontrol Listesi

Bu kontrol listesini kullanarak GitHub'a yüklemeden önce projenizi hazırlayın.

## ✅ Güvenlik Kontrolleri

- [x] `.gitignore` dosyası var ve doğru yapılandırılmış
- [ ] `.env` dosyası `.gitignore`'da (✅ var)
- [ ] `backend/.env` dosyası var mı kontrol edildi (✅ var - GitHub'a yüklenmeyecek)
- [ ] `node_modules/` `.gitignore`'da (✅ var)
- [ ] `venv/` `.gitignore`'da (✅ var)
- [ ] `__pycache__/` `.gitignore`'da (✅ var)
- [ ] `uploads/` `.gitignore`'da (✅ var)
- [ ] `*.log` `.gitignore`'da (✅ var)

## 📄 Gerekli Dosyalar

- [x] `README.md` - Var ve güncel
- [x] `LICENSE` - Var (MIT License)
- [x] `.env.example` - Oluşturuldu
- [x] `SECURITY.md` - Var
- [x] `CONTRIBUTING.md` - Oluşturuldu
- [x] `.github/ISSUE_TEMPLATE/` - Oluşturuldu
- [x] `.github/PULL_REQUEST_TEMPLATE.md` - Oluşturuldu

## 🔍 Son Kontroller

### 1. Hassas Bilgiler

Aşağıdaki dosyalarda hassas bilgiler (şifreler, API key'ler) hardcode edilmemiş olmalı:
- ✅ `backend/app/core/config.py` - Sadece default değerler var (güvenli)
- ✅ `docker-compose.yml` - Environment variable kullanıyor (güvenli)
- ✅ `docker-compose.prod.yml` - Environment variable kullanıyor (güvenli)

### 2. Default Değerler

Aşağıdaki dosyalarda default/example değerler var (normal):
- `docker-compose.yml` - Default değerler (development için OK)
- `README.md` - Example değerler (dokümantasyon için OK)
- `INSTALLATION.md` - Example değerler (dokümantasyon için OK)

### 3. Veritabanı ve Loglar

- [x] Veritabanı dosyaları (`.db`, `.sqlite`) `.gitignore`'da
- [x] Log dosyaları (`*.log`) `.gitignore`'da
- [x] `backend.log` ve `frontend.log` `.gitignore`'da

## 📦 Yüklenecek Dosyalar

### ✅ Yüklenecekler:
- Tüm kaynak kod dosyaları
- `README.md`, `LICENSE`, `SECURITY.md`
- `docker-compose.yml`, `docker-compose.prod.yml`
- `Dockerfile` dosyaları
- `.env.example`
- `.github/` klasörü (issue templates, PR template)
- Script dosyaları (`docker-up.sh`, `backup.sh`, vb.)
- Dokümantasyon dosyaları

### ❌ YÜKLENMEYECEKLER (.gitignore'da):
- `.env` dosyaları
- `node_modules/`
- `venv/`, `env/`
- `__pycache__/`
- `uploads/` klasörü
- `*.log` dosyaları
- `*.db`, `*.sqlite` dosyaları

## 🚀 Yükleme Öncesi Son Adımlar

1. **Git kurulu mu kontrol edin:**
   ```bash
   git --version
   ```
   Eğer yoksa: `sudo apt install git -y`

2. **Mevcut .env dosyasını kontrol edin:**
   ```bash
   cd /home/rampart/rampart
   ls -la backend/.env  # Varsa sorun yok, .gitignore'da
   ```

3. **Git durumunu kontrol edin:**
   ```bash
   git init
   git status
   ```
   
   `git status` çıktısında:
   - `.env` dosyası görünmemeli
   - `node_modules/` görünmemeli
   - `venv/` görünmemeli
   - Sadece kaynak kod ve dokümantasyon dosyaları görünmeli

4. **GitHub repository oluşturun:**
   - GitHub.com'da yeni repository oluşturun
   - README eklemeyin (zaten var)
   - License eklemeyin (zaten var)

5. **Yükleme yapın:**
   Detaylı adımlar için `GITHUB_SETUP.md` dosyasına bakın.

## ⚠️ Önemli Notlar

1. **`.env` Dosyası**: `backend/.env` dosyası varsa endişelenmeyin, `.gitignore`'da olduğu için yüklenmeyecek.

2. **Default Şifreler**: Kod içinde `admin123`, `archrampart_pass` gibi default değerler görünebilir. Bunlar sadece development için ve dokümantasyonda. Production'da `.env` dosyası ile değiştirilecek.

3. **İlk Commit**: İlk commit mesajınız açıklayıcı olsun:
   ```bash
   git commit -m "Initial commit: ArchRampart Audit Tool v1.0.0"
   ```

## ✅ Hazır mısınız?

Tüm kontrol listesini tamamladıysanız, `GITHUB_SETUP.md` dosyasındaki adımları takip ederek GitHub'a yükleyebilirsiniz!

**Başarılar!** 🚀

