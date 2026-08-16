import Foundation
import ProductClient
import UIKit

@MainActor
struct SampleProductImageLoader: ProductImageLoading {
    func loadProductImage() async throws -> ProductImage {
        let product = Product(
            id: "sample-jeans",
            name: String(localized: "Sample H&M Jeans"),
            imageURL: URL(string: "https://example.com/jeans.jpg")!
        )
        let originalImage = sampleImage(
            UIColor(red: 0.18, green: 0.33, blue: 0.52, alpha: 1),
            size: CGSize(width: 720, height: 960)
        )
        let processedImage = LiveImageProcessor().process(originalImage)

        return ProductImage(
            product: product,
            originalImage: originalImage,
            processedImage: processedImage
        )
    }
}

private func sampleImage(_ color: UIColor, size: CGSize) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { context in
        color.setFill()
        context.fill(CGRect(origin: .zero, size: size))
    }
}
