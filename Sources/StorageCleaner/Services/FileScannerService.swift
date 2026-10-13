import Foundation

struct ScannedFile {
    let url: URL
    let name: String
    let size: Int64
}

/// iOS, uygulamaların kullanıcının açıkça seçmediği dosyalara erişmesine izin vermez.
/// Bu servis yalnızca UIDocumentPicker ile kullanıcının seçtiği klasör/dosyaları tarar
/// (security-scoped bookmark erişimiyle).
enum FileScannerService {

    static func scan(directory url: URL) -> [ScannedFile] {
        guard url.startAccessingSecurityScopedResource() else { return [] }
        defer { url.stopAccessingSecurityScopedResource() }

        guard let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }

        var files: [ScannedFile] = []
        for case let fileURL as URL in enumerator {
            let values = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey])
            guard values?.isDirectory == false else { continue }
            let size = Int64(values?.fileSize ?? 0)
            files.append(ScannedFile(url: fileURL, name: fileURL.lastPathComponent, size: size))
        }
        return files.sorted { $0.size > $1.size }
    }

    @discardableResult
    static func delete(_ file: ScannedFile) -> Bool {
        (try? FileManager.default.removeItem(at: file.url)) != nil
    }
}
