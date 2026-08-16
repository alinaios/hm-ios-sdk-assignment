import Foundation
import ProductClient

struct LiveProductImageLoader: ProductImageLoading {
    private let imageProcessor: AppImageProcessing

    init(imageProcessor: AppImageProcessing = LiveImageProcessor()) {
        self.imageProcessor = imageProcessor
    }

    func loadProductImage() async throws -> ProductImage {
        var lastError: Error?

        for attempt in 0..<3 {
            do {
                return try await makeProductImageLoader().loadProductImage()
            } catch {
                lastError = error
                guard attempt < 2, shouldRetry(error) else {
                    throw error
                }

                try await Task.sleep(for: .seconds(1))
            }
        }

        throw lastError ?? URLError(.unknown)
    }

    private func makeProductImageLoader() -> ProductImageLoader {
        let urlSession = makeProductLoadingURLSession()
        return ProductImageLoader(
            productFetcher: HMBrowseProductClient(
                httpClient: URLSessionHTTPClient(urlSession: urlSession)
            ),
            imageLoader: RemoteImageLoader(
                dataLoader: URLSessionImageDataLoader(urlSession: urlSession)
            ),
            imageProcessor: imageProcessor
        )
    }

    private func makeProductLoadingURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 8
        configuration.timeoutIntervalForResource = 12
        configuration.waitsForConnectivity = false
        return URLSession(configuration: configuration)
    }

    private func shouldRetry(_ error: Error) -> Bool {
        guard let urlError = error as? URLError else {
            return false
        }

        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost, .cannotFindHost, .cannotConnectToHost, .timedOut:
            return true
        default:
            return false
        }
    }
}
