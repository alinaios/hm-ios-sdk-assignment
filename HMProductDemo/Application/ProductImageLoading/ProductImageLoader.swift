import Foundation
import ProductClient

struct ProductImageLoader: ProductImageLoading {
    private let productFetcher: ProductFetching
    private let imageLoader: ImageLoading
    private let imageProcessor: AppImageProcessing

    init(
        productFetcher: ProductFetching,
        imageLoader: ImageLoading,
        imageProcessor: AppImageProcessing
    ) {
        self.productFetcher = productFetcher
        self.imageLoader = imageLoader
        self.imageProcessor = imageProcessor
    }

    func loadProductImage() async throws -> ProductImage {
        let product = try await productFetcher.randomProduct()
        let image = try await imageLoader.image(from: product.imageURL)
        let processedImage = imageProcessor.process(image)

        return ProductImage(
            product: product,
            originalImage: image,
            processedImage: processedImage
        )
    }
}
