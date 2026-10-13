import Foundation

/// Yalnızca bu uygulamanın kendi sandbox'ı içindeki Caches/tmp dizinlerini yönetir.
/// iOS başka bir uygulamanın ya da sistemin önbelleğine erişim izni vermez.
enum AppCacheService {

    private static var cachesURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }

    private static var tmpURL: URL {
        URL(fileURLWithPath: NSTemporaryDirectory())
    }

    static func currentCacheSize() -> Int64 {
        directorySize(at: cachesURL) + directorySize(at: tmpURL)
    }

    @discardableResult
    static func clearCache() -> Int64 {
        let freedCaches = removeContents(of: cachesURL)
        let freedTmp = removeContents(of: tmpURL)
        return freedCaches + freedTmp
    }

    private static func directorySize(at url: URL) -> Int64 {
        guard let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else { return 0 }

        var total: Int64 = 0
        for case let fileURL as URL in enumerator {
            let values = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey])
            if values?.isDirectory == false {
                total += Int64(values?.fileSize ?? 0)
            }
        }
        return total
    }

    @discardableResult
    private static func removeContents(of url: URL) -> Int64 {
        let size = directorySize(at: url)
        guard let items = try? FileManager.default.contentsOfDirectory(
            at: url, includingPropertiesForKeys: nil
        ) else { return 0 }

        for item in items {
            try? FileManager.default.removeItem(at: item)
        }
        return size
    }
}
