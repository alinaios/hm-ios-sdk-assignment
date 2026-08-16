import UIKit

@MainActor
protocol AppImageProcessing {
    func process(_ image: UIImage) -> UIImage
}
