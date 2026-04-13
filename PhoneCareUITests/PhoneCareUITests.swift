import XCTest
@testable import PhoneCare

@MainActor
final class PhoneCareUITests: XCTestCase {
    private func makeApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [
            LaunchArguments.skipOnboardingForUITests,
            LaunchArguments.skipStoreKitForUITests
        ]
        return app
    }

    func testAppLaunches() throws {
        let app = makeApp()
        app.launch()
        XCTAssertTrue(app.exists)
    }

    func testMainTabNavigationShowsCoreScreens() throws {
        let app = makeApp()
        app.launch()

        XCTAssertTrue(app.otherElements["screen.dashboard"].waitForExistence(timeout: 5))

        app.tabBars.buttons["Storage"].tap()
        XCTAssertTrue(app.otherElements["screen.storage"].waitForExistence(timeout: 2))

        app.tabBars.buttons["Privacy"].tap()
        XCTAssertTrue(app.otherElements["screen.privacy"].waitForExistence(timeout: 2))

        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.otherElements["screen.settings"].waitForExistence(timeout: 2))
    }

    func testSettingsShowsStableLinksAndToggles() throws {
        let app = makeApp()
        app.launch()

        app.tabBars.buttons["Settings"].tap()

        XCTAssertTrue(app.switches["settings.notification.weekly"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.switches["settings.notification.duplicates"].exists)
        XCTAssertTrue(app.switches["settings.notification.battery"].exists)
        XCTAssertTrue(app.buttons["settings.about"].exists)
        XCTAssertTrue(app.buttons["settings.dataPrivacy"].exists)

        app.buttons["settings.about"].tap()
        XCTAssertTrue(app.otherElements["screen.about"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["about.privacyPolicy"].exists)
        XCTAssertTrue(app.buttons["about.termsOfService"].exists)
        XCTAssertTrue(app.buttons["about.contactSupport"].exists)
        XCTAssertTrue(app.buttons["about.rateApp"].exists)
    }
}
