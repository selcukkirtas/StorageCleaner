import UIKit
import WebKit

final class BrowserCleanerViewController: UITableViewController {

    private enum Row: Int, CaseIterable {
        case inAppWebCache
        case safariSettings

        var title: String {
            switch self {
            case .inAppWebCache: return "Uygulama İçi Web Önbelleğini Temizle"
            case .safariSettings: return "Safari Geçmiş/Veri Temizleme (Ayarlar)"
            }
        }

        var subtitle: String {
            switch self {
            case .inAppWebCache:
                return "Bu uygulamanın gömülü web görünümü (varsa) için depolanan çerez/önbellek verisini siler."
            case .safariSettings:
                return "iOS, üçüncü parti uygulamaların Safari'nin verilerini doğrudan silmesine izin vermez. Ayarlar > Safari > Geçmişi ve Site Verilerini Temizle ekranını açar."
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tarayıcı"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = Row(rawValue: indexPath.row)!
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = row.title
        cell.detailTextLabel?.text = row.subtitle
        cell.detailTextLabel?.numberOfLines = 0
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch Row(rawValue: indexPath.row)! {
        case .inAppWebCache:
            clearInAppWebCache()
        case .safariSettings:
            openSettings()
        }
    }

    private func clearInAppWebCache() {
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            dataStore.removeData(
                ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                for: records
            ) { [weak self] in
                DispatchQueue.main.async {
                    self?.showAlert(title: "Temizlendi", message: "\(records.count) kayıt silindi.")
                }
            }
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}
