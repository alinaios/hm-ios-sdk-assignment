import Foundation
import ProductClient

@MainActor
struct ProductViewModelFactory {
    func makeDefault() -> ProductViewModel {
        if ProcessInfo.processInfo.environment["UITEST_USE_SAMPLE_DATA"] == "1" {
            return ProductViewModel(
                productImageLoader: SampleProductImageLoader()
            )
        }

        let urlSession = makeProductLoadingURLSession()

        return ProductViewModel(
            productImageLoader: ProductImageLoader(
                productFetcher: HMBrowseProductClient(
                    httpClient: URLSessionHTTPClient(urlSession: urlSession)
                ),
                imageLoader: RemoteImageLoader(
                    dataLoader: URLSessionImageDataLoader(urlSession: urlSession)
                ),
                imageProcessor: LiveImageProcessor()
            )
        )
    }

    private func makeProductLoadingURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 8
        configuration.timeoutIntervalForResource = 12
        configuration.waitsForConnectivity = false
        return URLSession(configuration: configuration)
    }
}
