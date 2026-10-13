import UIKit
import UniformTypeIdentifiers

final class FileScannerViewController: UITableViewController, UIDocumentPickerDelegate {

    private var files: [ScannedFile] = []
    private let footerContainer = UIView()
    private let footerLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dosyalar"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Klasör Seç", style: .plain, target: self, action: #selector(pickFolder)
        )

        footerLabel.numberOfLines = 0
        footerLabel.font = .systemFont(ofSize: 13)
        footerLabel.textColor = .gray
        footerLabel.text = "iOS güvenlik modeli gereği yalnızca açıkça seçtiğiniz klasörler taranabilir; sistem genelinde otomatik tarama yapılamaz."
        footerLabel.translatesAutoresizingMaskIntoConstraints = false

        footerContainer.addSubview(footerLabel)
        NSLayoutConstraint.activate([
            footerLabel.leadingAnchor.constraint(equalTo: footerContainer.leadingAnchor, constant: 16),
            footerLabel.trailingAnchor.constraint(equalTo: footerContainer.trailingAnchor, constant: -16),
            footerLabel.topAnchor.constraint(equalTo: footerContainer.topAnchor, constant: 12),
            footerLabel.bottomAnchor.constraint(equalTo: footerContainer.bottomAnchor, constant: -12)
        ])

        tableView.tableFooterView = footerContainer
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = tableView.bounds.width
        guard width > 0 else { return }
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let height = footerContainer.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        if footerContainer.frame.height != height || footerContainer.frame.width != width {
            footerContainer.frame = CGRect(x: 0, y: 0, width: width, height: height)
            tableView.tableFooterView = footerContainer
        }
    }

    @objc private func pickFolder() {
        let picker: UIDocumentPickerViewController
        if #available(iOS 14.0, *) {
            picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
        } else {
            picker = UIDocumentPickerViewController(documentTypes: ["public.folder"], in: .open)
        }
        picker.delegate = self
        present(picker, animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let folderURL = urls.first else { return }
        files = FileScannerService.scan(directory: folderURL)
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        files.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let file = files[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? SubtitleCell
            ?? SubtitleCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = file.name
        cell.detailTextLabel?.text = StorageInfoService.formatted(file.size)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }

    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let file = files[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "Sil") { [weak self] _, _, completion in
            self?.confirmDelete(file: file, at: indexPath, completion: completion)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }

    private func confirmDelete(file: ScannedFile, at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(
            title: "Emin misiniz?",
            message: "\"\(file.name)\" (\(StorageInfoService.formatted(file.size))) kalıcı olarak silinecek. Bu işlem geri alınamaz.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Sil", style: .destructive) { [weak self] _ in
            guard let self = self else { completion(false); return }
            if FileScannerService.delete(file) {
                self.files.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                completion(true)
            } else {
                completion(false)
            }
        })
        alert.addAction(UIAlertAction(title: "Vazgeç", style: .cancel) { _ in completion(false) })
        present(alert, animated: true)
    }
}

final class SubtitleCell: UITableViewCell {}
