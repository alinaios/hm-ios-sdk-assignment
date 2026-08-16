import Foundation
import ProductClient

@MainActor
struct ProductViewModelFactory {
    func makeDefault() -> ProductViewModel {
        if ProcessInfo.processInfo.environment["UITEST_USE_SAMPLE_DATA"] == "1" {
            return ProductViewModel(
                productImageLoader: ProductImageLoader(
                    productFetcher: PreviewProductFetcher(),
                    imageLoader: PreviewImageLoader(),
                    imageProcessor: LiveImageProcessor()
                )
            )
        }

        return ProductViewModel(
            productImageLoader: ProductImageLoader(
                productFetcher: HMBrowseProductClient(),
                imageLoader: RemoteImageLoader(),
                imageProcessor: LiveImageProcessor()
            )
        )
    }
}
