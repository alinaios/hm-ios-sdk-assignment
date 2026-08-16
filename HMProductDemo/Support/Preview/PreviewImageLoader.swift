import Foundation
import UIKit

@MainActor
struct PreviewImageLoader: ImageLoading {
    func image(from url: URL) async throws -> UIImage {
        solidColorImage(
            UIColor(red: 0.18, green: 0.33, blue: 0.52, alpha: 1),
            size: CGSize(width: 720, height: 960)
        )
    }
}
