@testable import HMProductDemo

@MainActor
struct StubProductImageLoader: ProductImageLoading {
    let productImage: ProductImage

    func loadProductImage() async throws -> ProductImage {
        productImage
    }
}
