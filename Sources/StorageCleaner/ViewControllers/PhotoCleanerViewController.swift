import Photos
import UIKit

final class PhotoCleanerViewController: UITableViewController {

    private var groups: [PhotoCleanupGroup] = []
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Fotoğraflar"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Tara", style: .plain, target: self, action: #selector(startScan)
        )
    }

    @objc private func startScan() {
        activityIndicator.startAnimating()
        PhotoScannerService.requestAuthorization { [weak self] granted in
            guard let self = self else { return }
            guard granted else {
                self.activityIndicator.stopAnimating()
                self.showPermissionDeniedAlert()
                return
            }
            PhotoScannerService.scan { groups in
                self.activityIndicator.stopAnimating()
                self.groups = groups.filter { !$0.assets.isEmpty }
                self.tableView.reloadData()
            }
        }
    }

    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "İzin Gerekli",
            message: "Fotoğraflarınızı tarayabilmek için Ayarlar'dan fotoğraf erişimine izin verin.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ayarlar", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Table

    override func numberOfSections(in tableView: UITableView) -> Int { groups.count }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        groups[section].category.rawValue
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let group = groups[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(group.assets.count) öğe — \(StorageInfoService.formatted(group.totalBytes))"
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let group = groups[indexPath.section]

        let detail = PhotoGroupDetailViewController(
            category: group.category,
            assets: group.assets
        ) { [weak self] deletedAssets in
            self?.handleDeleted(deletedAssets, in: group.category)
        }
        navigationController?.pushViewController(detail, animated: true)
    }

    private func handleDeleted(_ deletedAssets: [PHAsset], in category: PhotoCleanupCategory) {
        guard let sectionIndex = groups.firstIndex(where: { $0.category == category }) else { return }
        let deletedSet = Set(deletedAssets.map { $0.localIdentifier })
        let remaining = groups[sectionIndex].assets.filter { !deletedSet.contains($0.localIdentifier) }

        if remaining.isEmpty {
            groups.remove(at: sectionIndex)
        } else {
            let deletedBytes = deletedAssets.reduce(Int64(0)) { sum, asset in
                sum + (PHAssetResource.assetResources(for: asset).first?.value(forKey: "fileSize") as? Int64 ?? 0)
            }
            let old = groups[sectionIndex]
            groups[sectionIndex] = PhotoCleanupGroup(
                category: old.category,
                assets: remaining,
                totalBytes: old.totalBytes - deletedBytes
            )
        }
        tableView.reloadData()
    }
}
