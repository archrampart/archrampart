# Güvenlik Durumu ve Önlemler

## 🔒 Güvenlik Durumu Raporu

Bu belge, ArchRampart Audit Tool'un güvenlik durumunu ve uygulanan önlemleri açıklar.

## ✅ Uygulanan Güvenlik Önlemleri

### 1. SQL Injection Koruması ✅
- **Durum**: Güvenli
- **Önlemler**:
  - SQLAlchemy ORM kullanılıyor (parametreli sorgular)
  - Raw SQL sorguları parametre binding ile yapılıyor
  - Tüm veritabanı işlemleri ORM üzerinden gerçekleştiriliyor
- **Kod Örnekleri**:
  ```python
  # Güvenli - ORM kullanımı
  user = db.query(User).filter(User.email == email).first()
  
  # Güvenli - Parametre binding
  db.execute(text("SELECT * FROM templates WHERE id = :id"), {"id": template_id})
  ```

### 2. XSS (Cross-Site Scripting) Koruması ✅
- **Durum**: Güvenli
- **Önlemler**:
  - **Frontend**: React'ın built-in XSS koruması kullanılıyor
    - `dangerouslySetInnerHTML` kullanılmıyor
    - Tüm user input'lar React tarafından otomatik escape ediliyor
  - **Backend**: Word generation'da HTML escaping uygulanıyor
    - `html.escape()` kullanılarak user input'lar escape ediliyor
    - Word generator'da tüm finding verileri escape ediliyor
- **Kod Örnekleri**:
  ```python
  # Backend - HTML escaping (Word generation)
  from html import escape as html_escape
  finding_title = html_escape(str(finding.title))
  ```

### 3. Authentication ve Authorization ✅
- **Durum**: Güvenli
- **Önlemler**:
  - JWT (JSON Web Tokens) tabanlı authentication
  - bcrypt ile password hashing (salt rounds: default)
  - Role-based access control (RBAC)
  - Token expiration (varsayılan: 24 saat)
- **Roller**:
  - `PLATFORM_ADMIN`: Tüm organizasyonlara erişim
  - `ORG_ADMIN`: Kendi organizasyonuna erişim
  - `AUDITOR`: Atandığı projelere erişim

### 4. Input Validation ✅
- **Durum**: Güvenli
- **Önlemler**:
  - Pydantic modelleri ile otomatik validation
  - FastAPI otomatik request validation
  - Type checking ve constraint validation
- **Örnekler**:
  ```python
  class FindingCreate(BaseModel):
      title: str  # Zorunlu alan
      description: Optional[str] = None
      severity: Severity = Severity.MEDIUM
  ```

### 5. File Upload Güvenliği ✅
- **Durum**: İyileştirildi
- **Önlemler**:
  - Dosya boyutu limiti (varsayılan: 10MB)
  - Dosya uzantısı kontrolü
  - Tehlikeli dosya tipleri engelleniyor
  - MIME type kontrolü
- **İzin Verilen Dosya Tipleri**:
  - Görüntüler: `.jpg`, `.jpeg`, `.png`, `.gif`, `.webp`, `.svg`
  - Dökümanlar: `.pdf`, `.doc`, `.docx`, `.xls`, `.xlsx`, `.ppt`, `.pptx`
  - Metin: `.txt`, `.csv`, `.md`
  - Arşivler: `.zip`, `.rar`, `.7z`
- **Engellenen Dosya Tipleri**:
  - Executables: `.exe`, `.bat`, `.cmd`, `.com`, `.scr`
  - Scripts: `.js`, `.sh`, `.bash`, `.ps1`, `.py`, `.rb`, `.pl`, `.php`
  - Web: `.html`, `.htm`, `.xhtml`, `.asp`, `.aspx`
  - Libraries: `.dll`, `.so`, `.dylib`, `.jar`

### 6. CORS (Cross-Origin Resource Sharing) ✅
- **Durum**: Yapılandırılabilir
- **Development**: Tüm origin'lere izin veriliyor (`*`)
- **Production**: `ALLOWED_ORIGINS` environment variable ile yapılandırılmalı
- **Öneri**: Production'da sadece güvenilir domain'leri ekleyin:
  ```bash
  ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
  ```

### 7. Password Güvenliği ✅
- **Durum**: Güvenli
- **Önlemler**:
  - bcrypt ile password hashing
  - Plain text password'lar veritabanında saklanmıyor
  - Password verification secure comparison ile yapılıyor

### 8. Session Management ✅
- **Durum**: Güvenli
- **Önlemler**:
  - JWT token'lar kullanılıyor
  - Token expiration kontrolü
  - Stateless authentication (server-side session yok)

## ⚠️ Dikkat Edilmesi Gerekenler

### 1. Production Deployment
- **SECRET_KEY**: Production'da güçlü, rastgele bir secret key kullanın
- **DEBUG**: Production'da `DEBUG=False` olmalı
- **ALLOWED_ORIGINS**: Production'da wildcard (`*`) kullanmayın
- **HTTPS**: Production'da mutlaka HTTPS kullanın

### 2. File Upload
- Upload edilen dosyalar güvenli bir dizinde saklanıyor
- Dosya adları UUID ile yeniden adlandırılıyor (path traversal koruması)
- Ancak upload edilen dosyaların içeriği kontrol edilmiyor (dosya içeriği validation önerilir)

### 3. Rate Limiting
- Şu anda rate limiting uygulanmıyor
- Production için rate limiting eklenmesi önerilir (örn: slowapi)

### 4. SQL Injection
- ORM kullanımı SQL injection riskini minimize ediyor
- Ancak `text()` ile yazılan raw SQL sorgularında parametre binding kullanıldığından emin olun

### 5. XSS
- Frontend'de React'ın built-in koruması var
- Backend'de Word generation'da HTML escaping yapılıyor
- Ancak tüm user input'ların escape edildiğinden emin olun

## 🔧 Güvenlik İyileştirme Önerileri

### 1. Rate Limiting
```python
# Örnek: slowapi kullanımı
from slowapi import Limiter
limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter

@router.post("/login")
@limiter.limit("5/minute")
async def login(...):
    ...
```

### 2. Content Security Policy (CSP)
Frontend'de CSP header'ları eklenebilir:
```
Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline';
```

### 3. File Content Validation
- Upload edilen dosyaların içeriği kontrol edilebilir (magic bytes)
- Virus scanning entegrasyonu düşünülebilir

### 4. Security Headers
```python
@app.middleware("http")
async def add_security_headers(request, call_next):
    response = await call_next(request)
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    return response
```

### 5. Input Sanitization
- HTML input'ları için bleach gibi kütüphaneler kullanılabilir
- Rich text editor kullanılırsa HTML sanitization zorunludur

## 📝 Güvenlik Checklist

### Backend
- [x] SQL Injection koruması (ORM)
- [x] XSS koruması (HTML escaping)
- [x] Authentication (JWT)
- [x] Authorization (RBAC)
- [x] Input validation (Pydantic)
- [x] File upload validation
- [x] Password hashing (bcrypt)
- [ ] Rate limiting
- [ ] Security headers
- [ ] File content validation

### Frontend
- [x] XSS koruması (React)
- [x] No dangerouslySetInnerHTML
- [x] Input validation
- [ ] Content Security Policy
- [ ] XSS protection headers

### Infrastructure
- [ ] HTTPS (production)
- [ ] Firewall rules
- [ ] Database encryption at rest
- [ ] Regular security updates
- [ ] Backup encryption

## 🔗 Güvenlik Kaynakları

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [FastAPI Security](https://fastapi.tiangolo.com/tutorial/security/)
- [React Security](https://reactjs.org/docs/dom-elements.html#dangerouslysetinnerhtml)

## 📞 Güvenlik Sorunları

Güvenlik açığı bulursanız, lütfen güvenli bir şekilde bildirin:
- Email: security@archrampart.com
- Website: https://archrampart.com

