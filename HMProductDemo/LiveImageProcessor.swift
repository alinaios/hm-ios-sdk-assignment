import ImageProcessor
import UIKit

struct LiveImageProcessor: AppImageProcessing {
    private let redMaskImageProcessor = RedMaskImageProcessor()

    func process(_ image: UIImage) -> UIImage {
        redMaskImageProcessor.applyRedMask(to: image)
    }
}
