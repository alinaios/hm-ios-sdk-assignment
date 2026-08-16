import Foundation
import UIKit

@MainActor
protocol ImageLoading {
    func image(from url: URL) async throws -> UIImage
}

enum ImageLoadingError: Error {
    case invalidData
    case invalidResponse
}

struct RemoteImageLoader: ImageLoading {
    func image(from url: URL) async throws -> UIImage {
        let (data, response) = try await URLSession.shared.data(from: url)

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
