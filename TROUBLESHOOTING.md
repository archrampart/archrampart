# Login Troubleshooting

This guide helps you troubleshoot login issues.

---

## 🇹🇷 Turkish / 🇬🇧 English

This document is available in both Turkish and English. Scroll down for the English version.

---

## 🇹🇷 Türkçe

### Hala Giriş Yapamıyorsanız

#### 1. Tarayıcı Console Kontrolü

1. Tarayıcıda F12 tuşuna basın
2. Console sekmesine gidin
3. Login yapmayı deneyin
4. Hata mesajlarını not edin

#### 2. Network Tab Kontrolü

1. F12 > Network sekmesi
2. Login yapmayı deneyin
3. `/api/v1/auth/login` isteğini bulun
4. İsteğin detaylarını kontrol edin:
   - Request URL doğru mu?
   - Request Headers doğru mu?
   - Request Payload doğru mu?
   - Response ne döndürüyor?

#### 3. Backend Kontrolü

```bash
# Backend loglarını kontrol edin
tail -f backend.log

# Backend çalışıyor mu?
curl http://localhost:8000/health

# Login API test
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@archrampart.com","password":"admin123"}'
```

#### 4. Frontend Kontrolü

```bash
# Frontend loglarını kontrol edin
tail -f frontend.log

# Frontend çalışıyor mu?
curl http://localhost:5173
```

#### 5. CORS Kontrolü

Backend'de CORS ayarlarını kontrol edin:
- `backend/app/core/config.py` dosyasında `ALLOWED_ORIGINS`
- `backend/app/main.py` dosyasında CORS middleware

#### 6. API URL Kontrolü

Frontend'in backend'e doğru URL'den bağlandığını kontrol edin:
- `frontend/src/api/client.ts` dosyasındaki `getApiBaseUrl()` fonksiyonu
- Tarayıcı console'da API isteklerinin URL'lerini kontrol edin

#### 7. Veritabanı Kontrolü

```bash
# Veritabanı bağlantısını test edin
PGPASSWORD=archrampart_pass psql -h localhost -U archrampart -d archrampart_audit -c "SELECT email FROM users;"
```

### Hızlı Çözüm

Eğer hala sorun varsa:

1. Backend'i yeniden başlatın:
```bash
cd /home/rampart/rampart
./stop.sh
cd backend
source venv/bin/activate
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

2. Frontend'i yeniden başlatın:
```bash
cd /home/rampart/rampart/frontend
npm run dev
```

3. Tarayıcı cache'ini temizleyin (Ctrl+Shift+Delete)

4. Tekrar deneyin

### Yaygın Hatalar ve Çözümleri

**"Invalid credentials" hatası:**
- Kullanıcı adı ve şifrenin doğru olduğundan emin olun
- Veritabanında kullanıcının mevcut olduğunu kontrol edin

**"Network Error" veya "CORS Error":**
- Backend'in çalıştığını kontrol edin
- CORS ayarlarını kontrol edin
- Frontend ve backend'in aynı network'te olduğundan emin olun

**"Connection refused":**
- Backend'in başlatıldığından emin olun
- Port 8000'in açık olduğundan emin olun

---

## 🇬🇧 English

### If You Still Cannot Log In

#### 1. Browser Console Check

1. Press F12 in your browser
2. Go to Console tab
3. Try to log in
4. Note error messages

#### 2. Network Tab Check

1. F12 > Network tab
2. Try to log in
3. Find `/api/v1/auth/login` request
4. Check request details:
   - Is Request URL correct?
   - Are Request Headers correct?
   - Is Request Payload correct?
   - What does Response return?

#### 3. Backend Check

```bash
# Check backend logs
tail -f backend.log

# Is backend running?
curl http://localhost:8000/health

# Login API test
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@archrampart.com","password":"admin123"}'
```

#### 4. Frontend Check

```bash
# Check frontend logs
tail -f frontend.log

# Is frontend running?
curl http://localhost:5173
```

#### 5. CORS Check

Check CORS settings in backend:
- `ALLOWED_ORIGINS` in `backend/app/core/config.py` file
- CORS middleware in `backend/app/main.py` file

#### 6. API URL Check

Check that frontend connects to backend from the correct URL:
- `getApiBaseUrl()` function in `frontend/src/api/client.ts` file
- Check API request URLs in browser console

#### 7. Database Check

```bash
# Test database connection
PGPASSWORD=archrampart_pass psql -h localhost -U archrampart -d archrampart_audit -c "SELECT email FROM users;"
```

### Quick Solution

If you still have issues:

1. Restart backend:
```bash
cd /home/rampart/rampart
./stop.sh
cd backend
source venv/bin/activate
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

2. Restart frontend:
```bash
cd /home/rampart/rampart/frontend
npm run dev
```

3. Clear browser cache (Ctrl+Shift+Delete)

4. Try again

### Common Errors and Solutions

**"Invalid credentials" error:**
- Make sure username and password are correct
- Check that user exists in database

**"Network Error" or "CORS Error":**
- Check that backend is running
- Check CORS settings
- Make sure frontend and backend are on the same network

**"Connection refused":**
- Make sure backend is started
- Make sure port 8000 is open
