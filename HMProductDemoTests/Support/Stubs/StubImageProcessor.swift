import UIKit
@testable import HMProductDemo

@MainActor
struct StubImageProcessor: AppImageProcessing {
    let image: UIImage

    func process(_ image: UIImage) -> UIImage {
        self.image
    }
}
