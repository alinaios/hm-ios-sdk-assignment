import ProductClient
import UIKit

struct ProductImageSwitcher {
    private let product: Product
    private let originalImage: UIImage
    private let processedImage: UIImage
    private var isShowingProcessedImage = false

    init(productImage: ProductImage) {
        product = productImage.product
        originalImage = productImage.originalImage
        processedImage = productImage.processedImage
    }

    var currentDisplay: ProductImageDisplay {
        ProductImageDisplay(
            product: product,
            image: isShowingProcessedImage ? processedImage : originalImage,
            displayModeTitle: isShowingProcessedImage
                ? AppString.displayModeProcessed.localized
                : AppString.displayModeOriginal.localized
        )
    }

    mutating func toggle() -> ProductImageDisplay {
        isShowingProcessedImage.toggle()
        return currentDisplay
    }
}
