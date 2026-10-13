import Photos
import UIKit

/// Bir kategorideki tüm öğeleri küçük resimlerle gösterir, kullanıcı tek tek
/// seçip çıkarabilir, ve yalnızca açıkça onaylandıktan sonra silme işlemi yapılır.
final class PhotoGroupDetailViewController: UIViewController {

    private let category: PhotoCleanupCategory
    private var assets: [PHAsset]
    /// Varsayılan olarak hepsi seçili gelir; kullanıcı istediğini çıkarabilir.
    private var selectedIndices: Set<Int>

    private let imageManager = PHCachingImageManager()
    private let collectionView: UICollectionView
    private let deleteButton = UIButton(type: .system)

    private let onDeleted: (([PHAsset]) -> Void)

    private static let cellID = "photoCell"

    init(category: PhotoCleanupCategory, assets: [PHAsset], onDeleted: @escaping ([PHAsset]) -> Void) {
        self.category = category
        self.assets = assets
        self.selectedIndices = Set(assets.indices)
        self.onDeleted = onDeleted

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        let side = (UIScreen.main.bounds.width - 8) / 4
        layout.itemSize = CGSize(width: side, height: side)
        layout.sectionInset = UIEdgeInsets(top: 4, left: 2, bottom: 4, right: 2)
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = category.rawValue
        view.backgroundColor = .systemBackgroundCompat

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: Self.cellID)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        deleteButton.backgroundColor = .systemRed
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.layer.cornerRadius = 10
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(deleteButton)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: deleteButton.topAnchor, constant: -12),

            deleteButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            deleteButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            deleteButton.heightAnchor.constraint(equalToConstant: 48)
        ])

        updateDeleteButtonTitle()

        for index in assets.indices {
            collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: [])
        }
    }

    private func updateDeleteButtonTitle() {
        let count = selectedIndices.count
        deleteButton.isEnabled = count > 0
        deleteButton.alpha = count > 0 ? 1 : 0.5
        deleteButton.setTitle("\(count) öğeyi Sil", for: .normal)
    }

    @objc private func deleteTapped() {
        let toDelete = selectedIndices.sorted().map { assets[$0] }
        guard !toDelete.isEmpty else { return }

        let totalBytes = toDelete.reduce(Int64(0)) { sum, asset in
            sum + (PHAssetResource.assetResources(for: asset).first?.value(forKey: "fileSize") as? Int64 ?? 0)
        }

        let alert = UIAlertController(
            title: "Emin misiniz?",
            message: "\(toDelete.count) öğe (\(StorageInfoService.formatted(totalBytes))) kalıcı olarak silinecek. Bu işlem geri alınamaz.",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "Sil", style: .destructive) { [weak self] _ in
            self?.performDelete(toDelete)
        })
        alert.addAction(UIAlertAction(title: "Vazgeç", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = deleteButton
            popover.sourceRect = deleteButton.bounds
        }
        present(alert, animated: true)
    }

    private func performDelete(_ toDelete: [PHAsset]) {
        PhotoScannerService.delete(assets: toDelete) { [weak self] success in
            guard let self = self else { return }
            guard success else {
                let fail = UIAlertController(title: "Silinemedi", message: "Lütfen tekrar deneyin.", preferredStyle: .alert)
                fail.addAction(UIAlertAction(title: "Tamam", style: .default))
                self.present(fail, animated: true)
                return
            }
            self.onDeleted(toDelete)
            let deletedSet = Set(toDelete.map { $0.localIdentifier })
            self.assets.removeAll { deletedSet.contains($0.localIdentifier) }
            self.selectedIndices = Set(self.assets.indices)
            self.collectionView.reloadData()
            for index in self.assets.indices {
                self.collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: [])
            }
            self.updateDeleteButtonTitle()
            if self.assets.isEmpty {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension PhotoGroupDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        assets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.cellID, for: indexPath) as! PhotoCell
        let asset = assets[indexPath.item]
        cell.checkmarkVisible = selectedIndices.contains(indexPath.item)

        let targetSize = CGSize(width: 160, height: 160)
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        imageManager.requestImage(
            for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options
        ) { image, _ in
            cell.imageView.image = image
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndices.insert(indexPath.item)
        (collectionView.cellForItem(at: indexPath) as? PhotoCell)?.checkmarkVisible = true
        updateDeleteButtonTitle()
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectedIndices.remove(indexPath.item)
        (collectionView.cellForItem(at: indexPath) as? PhotoCell)?.checkmarkVisible = false
        updateDeleteButtonTitle()
    }
}

final class PhotoCell: UICollectionViewCell {
    let imageView = UIImageView()
    private let checkmarkView = UIImageView()

    var checkmarkVisible: Bool = false {
        didSet {
            checkmarkView.isHidden = !checkmarkVisible
            contentView.layer.borderWidth = checkmarkVisible ? 2 : 0
            contentView.layer.borderColor = UIColor.systemRed.cgColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        checkmarkView.image = UIImage(systemNameCompat: "checkmark.circle.fill")
        checkmarkView.tintColor = .systemRed
        checkmarkView.backgroundColor = .white
        checkmarkView.layer.cornerRadius = 9
        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(checkmarkView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            checkmarkView.widthAnchor.constraint(equalToConstant: 18),
            checkmarkView.heightAnchor.constraint(equalToConstant: 18),
            checkmarkView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            checkmarkView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        checkmarkVisible = false
    }
}
