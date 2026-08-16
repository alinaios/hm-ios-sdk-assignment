import Foundation
import ProductClient

struct PreviewProductFetcher: ProductFetching {
    func randomProduct() async throws -> Product {
        Product(
            id: "preview-jeans",
            name: "Sample H&M Jeans",
            imageURL: URL(string: "https://example.com/jeans.jpg")!
        )
    }
}
