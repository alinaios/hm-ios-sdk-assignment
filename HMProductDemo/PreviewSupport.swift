import Foundation
import ProductClient
import UIKit

struct PreviewProductFetcher: ProductFetching {
    func randomProduct() async throws -> Product {
        Product(
            id: "preview-jeans",
            name: "Sample H&M Jeans",
            imageURL: URL(string: "https://example.com/jeans.jpg")!
        )
    }
}

@MainActor
struct PreviewImageLoader: ImageLoading {
    func image(from url: URL) async throws -> UIImage {
        solidColorImage(
            UIColor(red: 0.18, green: 0.33, blue: 0.52, alpha: 1),
            size: CGSize(width: 720, height: 960)
        )
    }
}

func solidColorImage(_ color: UIColor, size: CGSize) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { context in
        color.setFill()
        context.fill(CGRect(origin: .zero, size: size))
    }
}
