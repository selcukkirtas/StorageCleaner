import Photos
import UIKit

enum PhotoCleanupCategory: String, CaseIterable, Equatable {
    case screenshots = "Ekran Görüntüleri"
    case largeVideos = "Büyük Videolar"
    case similarPhotos = "Benzer Fotoğraflar"
}

struct PhotoCleanupGroup {
    let category: PhotoCleanupCategory
    let assets: [PHAsset]
    let totalBytes: Int64
}

final class PhotoScannerService {

    static func requestAuthorization(_ completion: @escaping (Bool) -> Void) {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async { completion(status == .authorized || status == .limited) }
            }
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async { completion(status == .authorized) }
            }
        }
    }

    /// Tarama işlemi ağır olabileceği için arka planda çalışır.
    static func scan(completion: @escaping ([PhotoCleanupGroup]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let screenshots = fetchAssets(mediaSubtype: .photoScreenshot)
            let videos = fetchLargeVideos(minimumBytes: 50 * 1024 * 1024)
            let similar = fetchSimilarPhotoGroups()

            let groups = [
                PhotoCleanupGroup(category: .screenshots, assets: screenshots, totalBytes: estimateSize(of: screenshots)),
                PhotoCleanupGroup(category: .largeVideos, assets: videos.assets, totalBytes: videos.totalBytes),
                PhotoCleanupGroup(category: .similarPhotos, assets: similar, totalBytes: estimateSize(of: similar))
            ]

            DispatchQueue.main.async { completion(groups) }
        }
    }

    private static func fetchAssets(mediaSubtype: PHAssetMediaSubtype) -> [PHAsset] {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "(mediaSubtypes & %d) != 0", mediaSubtype.rawValue)
        let result = PHAsset.fetchAssets(with: options)
        var assets: [PHAsset] = []
        result.enumerateObjects { asset, _, _ in assets.append(asset) }
        return assets
    }

    private static func fetchLargeVideos(minimumBytes: Int64) -> (assets: [PHAsset], totalBytes: Int64) {
        let options = PHFetchOptions()
        let result = PHAsset.fetchAssets(with: .video, options: options)

        var assets: [PHAsset] = []
        var total: Int64 = 0
        result.enumerateObjects { asset, _, _ in
            let size = approximateFileSize(of: asset)
            if size >= minimumBytes {
                assets.append(asset)
                total += size
            }
        }
        return (assets, total)
    }

    /// Basit algılama: aynı çekim zamanı + yakın piksel boyutlarına sahip fotoğrafları
    /// "benzer" (muhtemel yinelenen burst/ekran) olarak gruplar. Tam içerik karşılaştırması
    /// (perceptual hash) daha yüksek doğruluk ister ama bu, hızlı ve ucuz bir ilk filtredir.
    private static func fetchSimilarPhotoGroups() -> [PHAsset] {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let result = PHAsset.fetchAssets(with: .image, options: options)

        var allAssets: [PHAsset] = []
        result.enumerateObjects { asset, _, _ in allAssets.append(asset) }

        var duplicates: [PHAsset] = []
        var previous: PHAsset?
        for asset in allAssets {
            defer { previous = asset }
            guard let prev = previous,
                  let prevDate = prev.creationDate,
                  let date = asset.creationDate else { continue }

            let closeInTime = abs(date.timeIntervalSince(prevDate)) < 2.0
            let sameSize = prev.pixelWidth == asset.pixelWidth && prev.pixelHeight == asset.pixelHeight
            if closeInTime && sameSize {
                duplicates.append(asset)
            }
        }
        return duplicates
    }

    private static func approximateFileSize(of asset: PHAsset) -> Int64 {
        let resources = PHAssetResource.assetResources(for: asset)
        for resource in resources {
            if let sizeValue = resource.value(forKey: "fileSize") as? Int64 {
                return sizeValue
            }
        }
        return 0
    }

    private static func estimateSize(of assets: [PHAsset]) -> Int64 {
        assets.reduce(0) { $0 + approximateFileSize(of: $1) }
    }

    static func delete(assets: [PHAsset], completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assets as NSArray)
        }, completionHandler: { success, _ in
            DispatchQueue.main.async { completion(success) }
        })
    }
}
