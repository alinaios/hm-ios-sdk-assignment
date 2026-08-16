import Foundation
import Testing
@testable import ProductClient

struct ProductSelectorTests {
    @Test
    func returnsNilForEmptyProductList() {
        let selector = RandomProductSelector()

        #expect(selector.selectProduct(from: []) == nil)
    }

    @Test
    func returnsProductFromNonEmptyProductList() {
        let product = Product(
            id: "1",
            name: "Slim Jeans",
            imageURL: URL(string: "https://image.hm.com/product.jpg")!
        )
        let selector = RandomProductSelector()

        #expect(selector.selectProduct(from: [product]) == product)
    }
}
