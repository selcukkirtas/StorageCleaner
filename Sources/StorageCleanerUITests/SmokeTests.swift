import XCTest

final class SmokeTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    func testTabsAndSystemDataGuide() throws {
        let app = XCUIApplication()
        app.launch()

        attach(app, name: "01_dashboard")

        app.tabBars.buttons["Fotoğraflar"].tap()
        sleep(1)
        attach(app, name: "02_photos")

        app.navigationBars.buttons["Tara"].tap()
        sleep(1)

        // Sistem izin diyaloğu çıkarsa onayla (springboard alert).
        let allowButtons = ["OK", "Allow", "İzin Ver", "Tüm Fotoğraflara İzin Ver", "Allow Full Access"]
        for title in allowButtons {
            let button = XCUIApplication(bundleIdentifier: "com.apple.springboard").buttons[title]
            if button.waitForExistence(timeout: 2) {
                button.tap()
                break
            }
        }
        sleep(2)
        attach(app, name: "03_photos_after_scan")

        app.tabBars.buttons["Dosyalar"].tap()
        sleep(1)
        attach(app, name: "04_files")

        app.tabBars.buttons["Tarayıcı"].tap()
        sleep(1)
        attach(app, name: "05_browser")

        app.tabBars.buttons["Depolama"].tap()
        sleep(1)
        app.buttons["\"Sistem Verisi\" Nedir, Nasıl Küçültülür?"].tap()
        sleep(1)
        attach(app, name: "06_system_data_guide")
    }

    private func attach(_ app: XCUIApplication, name: String) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
