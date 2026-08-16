import UIKit
@testable import HMProductDemo

@MainActor
struct StubImageLoader: ImageLoading {
    let image: UIImage

    func image(from url: URL) async throws -> UIImage {
        image
    }
}
