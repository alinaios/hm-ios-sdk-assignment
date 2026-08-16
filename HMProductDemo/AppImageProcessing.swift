import ImageProcessor
import UIKit

@MainActor
protocol AppImageProcessing {
    func process(_ image: UIImage) -> UIImage
}

struct LiveImageProcessor: AppImageProcessing {
    private let redMaskImageProcessor = RedMaskImageProcessor()

    func process(_ image: UIImage) -> UIImage {
        redMaskImageProcessor.applyRedMask(to: image)
    }
}
