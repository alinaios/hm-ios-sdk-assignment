@testable import HMProductDemo

@MainActor
final class SequencedProductImageLoader: ProductImageLoading {
    private let productImages: [ProductImage]
    private var index = 0

    init(productImages: [ProductImage]) {
        self.productImages = productImages
    }

    func loadProductImage() async throws -> ProductImage {
        let productImage = productImages[min(index, productImages.count - 1)]
        index += 1
        return productImage
    }
}
