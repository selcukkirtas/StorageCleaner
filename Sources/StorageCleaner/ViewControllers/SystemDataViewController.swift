import UIKit

/// iOS, "Sistem Verisi" kategorisine üçüncü parti uygulamalar için hiçbir okuma/silme API'si
/// sunmaz (Apple'ın kendi Ayarlar uygulaması hariç). Bu ekran bu gerçeği açıkça anlatır ve
/// kullanıcıyı gerçekten işe yarayan, Apple'ın da önerdiği manuel adımlara yönlendirir.
final class SystemDataViewController: UITableViewController {

    private let tips = SystemDataGuide.tips

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sistem Verisi"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
    }

    override func numberOfSections(in tableView: UITableView) -> Int { 2 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : tips.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? nil : "Yapabilecekleriniz"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "info")
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = .systemFont(ofSize: 14)
            cell.textLabel?.text = "\"Sistem Verisi\", iOS'un kendi önbellekleri, geçici dosyaları ve Apple tarafından yönetilen diğer verilerden oluşur. Apple, App Store'daki hiçbir uygulamaya bu alanı okuma veya silme izni vermez — bu bir eksiklik değil, güvenlik/sandbox tasarımıdır. Aşağıdaki adımlar bu alanı küçültmenin gerçekten işe yarayan yollarıdır."
            cell.selectionStyle = .none
            return cell
        }

        let tip = tips[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = tip.title
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = tip.detail
        cell.detailTextLabel?.numberOfLines = 0
        return cell
    }
}
