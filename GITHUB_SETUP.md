# GitHub'a Yükleme Adımları

Bu doküman, ArchRampart Audit Tool projenizi GitHub'a yüklemek için gereken adımları açıklar.

## 🔧 Ön Hazırlık

### 1. Git Kurulumu

Eğer sisteminizde Git yüklü değilse:

```bash
sudo apt update
sudo apt install git -y
```

### 2. Git Yapılandırması

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## 📦 GitHub Repository Oluşturma

### 1. GitHub'da Repository Oluşturun

1. GitHub.com'a gidin ve giriş yapın
2. Sağ üst köşedeki "+" ikonuna tıklayın
3. "New repository" seçin
4. Repository bilgilerini doldurun:
   - **Repository name**: `archrampart-audit-tool` (veya istediğiniz isim)
   - **Description**: `Enterprise-Grade On-Premise Security and Compliance Audit Management Platform`
   - **Visibility**: Public veya Private (tercihinize göre)
   - ⚠️ **ÖNEMLİ**: "Initialize this repository with a README" seçeneğini **işaretlemeyin**
5. "Create repository" butonuna tıklayın

### 2. Repository URL'ini Not Alın

GitHub size bir URL verecek, örneğin:
```
https://github.com/yourusername/archrampart-audit-tool.git
```
veya
```
git@github.com:yourusername/archrampart-audit-tool.git
```

## 🚀 Projeyi Git'e Ekleyip Yükleme

Proje dizininizde (`/home/rampart/rampart`) şu komutları çalıştırın:

### 1. Git Repository'sini Başlatın

```bash
cd /home/rampart/rampart
git init
```

### 2. Tüm Dosyaları Ekleyin

```bash
git add .
```

### 3. İlk Commit'i Oluşturun

```bash
git commit -m "Initial commit: ArchRampart Audit Tool v1.0.0"
```

### 4. GitHub Repository'sini Remote Olarak Ekleyin

```bash
git remote add origin https://github.com/yourusername/archrampart-audit-tool.git
```

⚠️ **DİKKAT**: `yourusername` ve `archrampart-audit-tool` kısımlarını kendi repository bilgilerinizle değiştirin!

### 5. Ana Branch'i Oluşturun

```bash
git branch -M main
```

### 6. GitHub'a Yükleyin

```bash
git push -u origin main
```

Bu adımda GitHub kullanıcı adı ve şifreniz istenebilir. Eğer 2FA (Two-Factor Authentication) etkinse, bir Personal Access Token kullanmanız gerekebilir.

## 🔐 Personal Access Token (GitHub Authentication)

Eğer GitHub'da 2FA etkinse veya HTTPS ile push yaparken sorun yaşıyorsanız:

1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. "Generate new token" → "Generate new token (classic)" seçin
3. İzinler:
   - ✅ `repo` (Full control of private repositories)
4. Token oluşturun ve kopyalayın
5. Push yaparken şifre yerine bu token'ı kullanın

Alternatif olarak SSH kullanabilirsiniz:

```bash
git remote set-url origin git@github.com:yourusername/archrampart-audit-tool.git
```

## ✅ Kontrol

Yükleme başarılı olduktan sonra:

1. GitHub repository sayfanızı yenileyin
2. Tüm dosyaların yüklendiğini kontrol edin
3. README.md dosyasının düzgün göründüğünü kontrol edin

## 📝 Sonraki Adımlar (Opsiyonel)

### 1. GitHub Pages (Opsiyonel)

Eğer projenizi GitHub Pages'te host etmek isterseniz, repository ayarlarından Pages özelliğini etkinleştirebilirsiniz.

### 2. GitHub Actions (CI/CD)

CI/CD pipeline eklemek için `.github/workflows/` klasörü oluşturup workflow dosyaları ekleyebilirsiniz.

### 3. Releases ve Tags

Versiyonlama için:

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

## 🆘 Sorun Giderme

### "Permission denied" hatası

SSH key kullanın veya Personal Access Token ile deneyin.

### "Repository not found" hatası

Repository URL'inin doğru olduğundan emin olun.

### Büyük dosyalar için

Eğer dosyalar çok büyükse, `.gitignore` dosyasını kontrol edin. `node_modules`, `venv`, `.env` gibi dosyalar ignore edilmelidir.

## 📋 Checklist

Yüklemeden önce kontrol edin:

- [ ] `.env` dosyası yok (sadece `.env.example` var)
- [ ] `node_modules/` klasörü `.gitignore`'da
- [ ] `venv/` veya `env/` klasörü `.gitignore`'da
- [ ] `__pycache__/` klasörleri `.gitignore`'da
- [ ] `uploads/` klasörü `.gitignore`'da (veritabanı dosyaları hariç)
- [ ] `*.log` dosyaları `.gitignore`'da
- [ ] `LICENSE` dosyası var
- [ ] `README.md` güncel
- [ ] `.env.example` dosyası var ve doğru şekilde doldurulmuş
- [ ] Hassas bilgiler (şifreler, API key'ler) kod içinde hardcode edilmemiş

## 🎉 Tamamlandı!

Projeniz artık GitHub'da! Artık:

- Diğer geliştiricilerle işbirliği yapabilirsiniz
- Issues ve Pull Requests kullanabilirsiniz
- GitHub Actions ile CI/CD kurabilirsiniz
- Releases oluşturabilirsiniz

Başarılar! 🚀

