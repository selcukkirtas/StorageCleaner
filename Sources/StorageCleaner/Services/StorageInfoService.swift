import Foundation

struct StorageInfo {
    let totalCapacity: Int64
    let availableCapacity: Int64

    var usedCapacity: Int64 { max(0, totalCapacity - availableCapacity) }
    var usedFraction: Double {
        guard totalCapacity > 0 else { return 0 }
        return Double(usedCapacity) / Double(totalCapacity)
    }
}

/// Cihazın gerçek toplam/boş depolama bilgisini okur.
/// Not: iOS üçüncü parti uygulamalara "Sistem Verisi" dökümünü (Ayarlar > iPhone Depolama Alanı
/// içindeki kırılım) açmaz; burada sadece toplam/boş/kullanılan alan hesaplanabilir.
enum StorageInfoService {

    static func currentStorageInfo() -> StorageInfo? {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory())
        guard let values = try? fileURL.resourceValues(forKeys: [
            .volumeTotalCapacityKey,
            .volumeAvailableCapacityForImportantUsageKey
        ]) else { return nil }

        guard let total = values.volumeTotalCapacity,
              let available = values.volumeAvailableCapacityForImportantUsage else {
            return nil
        }

        return StorageInfo(totalCapacity: Int64(total), availableCapacity: available)
    }

    static func formatted(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
}
