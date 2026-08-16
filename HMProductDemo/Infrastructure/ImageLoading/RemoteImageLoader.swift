import Foundation
import UIKit

struct RemoteImageLoader: ImageLoading {
    private let dataLoader: ImageDataLoading

    init(dataLoader: ImageDataLoading = URLSessionImageDataLoader()) {
        self.dataLoader = dataLoader
    }

    func image(from url: URL) async throws -> UIImage {
        let (data, response) = try await dataLoader.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw ImageLoadingError.invalidResponse
        }

        guard let image = UIImage(data: data) else {
            throw ImageLoadingError.invalidData
        }

        return image
    }
}
