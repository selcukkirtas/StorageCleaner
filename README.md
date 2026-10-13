# StorageCleaner (iOS / iPadOS)

Native UIKit uygulaması. iOS'un izin verdiği ölçüde depolama alanı temizler.

## Önemli kısıt: "Sistem Verisi"

iOS, Ayarlar > Genel > iPhone Depolama Alanı'ndaki **"Sistem Verisi"** kategorisine
hiçbir üçüncü parti uygulamaya (App Store kurallarına uyan hiçbir uygulamaya) okuma
veya silme erişimi vermez. Bu bir sandbox/güvenlik tasarımıdır, eksiklik değildir.
Bu nedenle uygulama bu alanı "temizlemez"; bunun yerine:

- `SystemDataViewController`: Sistem Verisi'nin ne olduğunu ve Apple'ın kendi
  önerdiği gerçek küçültme yöntemlerini (Mesaj ekleri, Safari verisi, uygulama
  boşaltma, yeniden başlatma) gösterir.

## Gerçekten temizlenen alanlar

- **Fotoğraflar/Videolar** (`PhotoScannerService`): Ekran görüntüleri, büyük
  videolar, zaman+boyut yakınlığına göre benzer/yinelenen fotoğraflar. PhotosKit
  üzerinden kullanıcı onayıyla silinir.
- **Dosyalar** (`FileScannerService`): `UIDocumentPickerViewController` ile
  kullanıcının açıkça seçtiği klasörler taranır, büyükten küçüğe sıralanır, tek
  tek silinebilir.
- **Uygulama önbelleği** (`AppCacheService`): Sadece bu uygulamanın kendi
  `Caches/` ve `tmp/` dizinleri.
- **Web verisi** (`BrowserCleanerViewController`): Uygulama içi `WKWebView`
  verisi programatik olarak temizlenir; Safari'nin kendi verisi için Ayarlar'a
  yönlendirme yapılır (iOS bunun dışında izin vermiyor).

## Platform / Hedefler

- Min deployment target: **iOS/iPadOS 15.0** (bu projeyi derleyen Xcode sürümü
  15.0 altını desteklemiyor; App Store'un güncel Xcode zorunluluğu nedeniyle de
  pratikte iPhone 6/iPad 2 gibi çok eski cihazlar artık hedeflenemiyor).
- UI: UIKit, programatik layout (storyboard yok, LaunchScreen hariç).
- Proje dosyası `project.yml` üzerinden [XcodeGen](https://github.com/yonaskolb/XcodeGen)
  ile üretilir.

## Geliştirme

```bash
brew install xcodegen   # yoksa
xcodegen generate
open StorageCleaner.xcodeproj
```

## Yapılacaklar / sonraki adımlar

- Gerçek bir App Icon seti ekle (`Assets.xcassets/AppIcon.appiconset` şu an
  placeholder).
- Benzer fotoğraf tespitini perceptual hash (örn. Vision framework) ile
  güçlendir — şu an zaman+boyut yakınlığına dayalı basit bir sezgisel kullanılıyor.
- Dosya tarayıcıda security-scoped bookmark'ları kalıcı saklayarak kullanıcının
  tekrar tekrar klasör seçmesini önle.
