import Foundation

@MainActor
protocol ProductImageLoading {
    func loadProductImage() async throws -> ProductImage
}
