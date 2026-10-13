import UIKit

final class RootTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let dashboard = DashboardViewController()
        dashboard.tabBarItem = UITabBarItem(title: "Depolama", image: UIImage(systemNameCompat: "gauge"), tag: 0)

        let photos = PhotoCleanerViewController()
        photos.tabBarItem = UITabBarItem(title: "Fotoğraflar", image: UIImage(systemNameCompat: "photo.on.rectangle"), tag: 1)

        let files = FileScannerViewController()
        files.tabBarItem = UITabBarItem(title: "Dosyalar", image: UIImage(systemNameCompat: "folder"), tag: 2)

        let browser = BrowserCleanerViewController()
        browser.tabBarItem = UITabBarItem(title: "Tarayıcı", image: UIImage(systemNameCompat: "globe"), tag: 3)

        viewControllers = [dashboard, photos, files, browser].map {
            UINavigationController(rootViewController: $0)
        }
    }
}

extension UIImage {
    /// iOS 12 cihazlarda SF Symbols bulunmadığı için güvenli bir fallback sağlar.
    convenience init?(systemNameCompat name: String) {
        if #available(iOS 13.0, *) {
            self.init(systemName: name)
        } else {
            self.init(named: name)
        }
    }
}
