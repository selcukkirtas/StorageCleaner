import UIKit

final class DashboardViewController: UIViewController {

    private let progressView = UIProgressView(progressViewStyle: .default)
    private let usedLabel = UILabel()
    private let freeLabel = UILabel()
    private let totalLabel = UILabel()
    private let appCacheLabel = UILabel()
    private let clearAppCacheButton = UIButton(type: .system)
    private let systemDataButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Depolama"
        view.backgroundColor = .systemBackgroundCompat

        setupLayout()
        reload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    private func setupLayout() {
        [usedLabel, freeLabel, totalLabel, appCacheLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.numberOfLines = 0
        }
        usedLabel.font = .boldSystemFont(ofSize: 28)

        clearAppCacheButton.setTitle("Uygulama Önbelleğini Temizle", for: .normal)
        clearAppCacheButton.addTarget(self, action: #selector(clearAppCacheTapped), for: .touchUpInside)
        clearAppCacheButton.translatesAutoresizingMaskIntoConstraints = false

        systemDataButton.setTitle("\"Sistem Verisi\" Nedir, Nasıl Küçültülür?", for: .normal)
        systemDataButton.addTarget(self, action: #selector(systemDataTapped), for: .touchUpInside)
        systemDataButton.translatesAutoresizingMaskIntoConstraints = false
        systemDataButton.titleLabel?.numberOfLines = 0
        systemDataButton.titleLabel?.textAlignment = .center

        progressView.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [
            usedLabel, progressView, freeLabel, totalLabel, appCacheLabel, clearAppCacheButton, systemDataButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24)
        ])
    }

    private func reload() {
        if let info = StorageInfoService.currentStorageInfo() {
            usedLabel.text = "Kullanılan: \(StorageInfoService.formatted(info.usedCapacity))"
            freeLabel.text = "Boş Alan: \(StorageInfoService.formatted(info.availableCapacity))"
            totalLabel.text = "Toplam Kapasite: \(StorageInfoService.formatted(info.totalCapacity))"
            progressView.progress = Float(info.usedFraction)
        } else {
            usedLabel.text = "Depolama bilgisi okunamadı"
        }

        let cacheSize = AppCacheService.currentCacheSize()
        appCacheLabel.text = "Uygulama önbelleği: \(StorageInfoService.formatted(cacheSize))"
    }

    @objc private func clearAppCacheTapped() {
        let freed = AppCacheService.clearCache()
        reload()
        let alert = UIAlertController(
            title: "Temizlendi",
            message: "\(StorageInfoService.formatted(freed)) boşaltıldı.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }

    @objc private func systemDataTapped() {
        navigationController?.pushViewController(SystemDataViewController(), animated: true)
    }
}

extension UIColor {
    static var systemBackgroundCompat: UIColor {
        if #available(iOS 13.0, *) { return .systemBackground }
        return .white
    }
}
