import ProductClient
import UIKit
import XCTest
@testable import HMProductDemo

@MainActor
final class ProductImageSwitcherTests: XCTestCase {
    func testToggleAlternatesBetweenOriginalAndProcessedImage() {
        let product = Product(
            id: "1",
            name: "Test Jeans",
            imageURL: URL(string: "https://example.com/image.jpg")!
        )
        let originalImage = testImage(.blue, size: CGSize(width: 10, height: 10))
        let processedImage = testImage(.red, size: CGSize(width: 10, height: 10))
        var switcher = ProductImageSwitcher(
            productImage: ProductImage(
                product: product,
                originalImage: originalImage,
                processedImage: processedImage
            )
        )

        let initialDisplay = switcher.currentDisplay
        let processedDisplay = switcher.toggle()
        let originalDisplay = switcher.toggle()

        XCTAssertEqual(initialDisplay.product, product)
        XCTAssertEqual(initialDisplay.image.pngData(), originalImage.pngData())
        XCTAssertEqual(initialDisplay.displayModeTitle, "Original image")
        XCTAssertEqual(processedDisplay.image.pngData(), processedImage.pngData())
        XCTAssertEqual(processedDisplay.displayModeTitle, "Processed image")
        XCTAssertEqual(originalDisplay.image.pngData(), originalImage.pngData())
        XCTAssertEqual(originalDisplay.displayModeTitle, "Original image")
    }
}
