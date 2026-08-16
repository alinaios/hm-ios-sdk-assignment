import Foundation

public protocol ProductFetching: Sendable {
    func randomProduct() async throws -> Product
}

public enum ProductClientError: Error, Equatable, Sendable {
    case invalidResponse
    case noProducts
}

public struct HMBrowseProductClient: ProductFetching {
    private let endpoint: URL
    private let httpClient: HTTPClient
    private let responseDecoder: ProductResponseDecoder
    private let productSelector: ProductSelecting

    public init(
        endpoint: URL? = nil,
        httpClient: HTTPClient = URLSessionHTTPClient(),
        responseDecoder: ProductResponseDecoder = ProductResponseDecoder(),
        productSelector: ProductSelecting = RandomProductSelector()
    ) {
        self.endpoint = endpoint ?? URL(
            string: "https://api.hm.com/search-services/v1/sv_se/search/resultpage?touchPoint=ios&query=jeans&page=1"
        )!
        self.httpClient = httpClient
        self.responseDecoder = responseDecoder
        self.productSelector = productSelector
    }

    public func randomProduct() async throws -> Product {
        let request = URLRequest(url: endpoint)
        let data = try await httpClient.data(for: request)
        let products = try responseDecoder.decodeProducts(from: data)

        guard let product = productSelector.selectProduct(from: products) else {
            throw ProductClientError.noProducts
        }

        return product
    }
}
