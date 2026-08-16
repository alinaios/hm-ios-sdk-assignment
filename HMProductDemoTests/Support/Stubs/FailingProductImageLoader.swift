import Foundation
@testable import HMProductDemo

@MainActor
struct FailingProductImageLoader: ProductImageLoading {
    let error: Error

    init(error: Error = URLError(.notConnectedToInternet)) {
        self.error = error
    }

    func loadProductImage() async throws -> ProductImage {
        throw error
    }
}
