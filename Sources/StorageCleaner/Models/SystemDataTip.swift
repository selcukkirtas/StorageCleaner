import Foundation

/// "Sistem Verisi" kategorisi iOS'ta hiçbir public API ile üçüncü parti uygulamalara açılmaz.
/// Bu nedenle burada sunulanlar, Apple'ın kendi desteğinin de önerdiği, kullanıcının
/// Ayarlar üzerinden kendisinin uygulayabileceği gerçek ve etkili adımlardır.
struct SystemDataTip {
    let title: String
    let detail: String
}

enum SystemDataGuide {
    static let tips: [SystemDataTip] = [
        SystemDataTip(
            title: "Mesajlardaki ekleri temizle",
            detail: "Ayarlar > Genel > iPhone Depolama Alanı > Mesajlar üzerinden eski fotoğraf/video eklerini ve büyük konuşmaları sil. Sistem Verisi'nin en büyük kaynaklarından biridir."
        ),
        SystemDataTip(
            title: "Safari geçmişi ve site verisini temizle",
            detail: "Ayarlar > Safari > Geçmişi ve Web Sitesi Verilerini Temizle. Yıllar içinde birikmiş önbellek burada büyük yer kaplayabilir."
        ),
        SystemDataTip(
            title: "Kullanılmayan uygulamaları boşalt (Offload)",
            detail: "Ayarlar > Genel > iPhone Depolama Alanı > Kullanılmayan Uygulamaları Boşalt. Uygulama verisi kalır, ikon silinir; tekrar indirince veri geri gelir."
        ),
        SystemDataTip(
            title: "Cihazı yeniden başlat",
            detail: "iOS periyodik olarak geçici sistem önbelleklerini yeniden başlatma sırasında temizler. Sistem Verisi şişkinliğinin basit ama etkili bir çözümü."
        ),
        SystemDataTip(
            title: "Çevrimdışı müzik/podcast indirmelerini kontrol et",
            detail: "Apple Music, Spotify gibi uygulamaların indirilen içerikleri bazen Sistem Verisi/Diğer olarak sayılır. İlgili uygulama içinden indirilenleri temizle."
        ),
        SystemDataTip(
            title: "iOS güncellemesi sonrası geçici dosyaları bekle",
            detail: "Büyük bir güncellemeden sonra Sistem Verisi geçici olarak şişer; birkaç gün içinde veya bir yeniden başlatmayla otomatik küçülür."
        )
    ]
}
