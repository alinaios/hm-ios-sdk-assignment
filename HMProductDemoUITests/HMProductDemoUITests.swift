import XCTest

final class HMProductDemoUITests: XCTestCase {
    func testDisplaysSampleProduct() {
        let app = XCUIApplication()
        app.launchEnvironment["UITEST_USE_SAMPLE_DATA"] = "1"
        app.launch()

        XCTAssertTrue(app.staticTexts["Sample H&M Jeans"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.images["productImage"].exists)
        XCTAssertTrue(app.staticTexts["displayMode"].exists)
        XCTAssertTrue(app.buttons["newProductButton"].exists)
    }
}
