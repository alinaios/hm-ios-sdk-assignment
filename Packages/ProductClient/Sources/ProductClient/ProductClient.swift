import Foundation

public protocol ProductFetching: Sendable {
    func randomProduct() async throws -> Product
}

public enum ProductClientError: Error, Equatable, Sendable {
    case invalidURL
    case invalidResponse
    case noProducts
}

public struct HMBrowseProductClient: ProductFetching {
    private let endpoint: APIEndpoint
    private let httpClient: HTTPClient
    private let responseDecoder: ProductResponseDecoder
    private let productSelector: ProductSelecting

    public init(
        endpoint: APIEndpoint? = nil,
        httpClient: HTTPClient = URLSessionHTTPClient(),
        responseDecoder: ProductResponseDecoder = ProductResponseDecoder(),
        productSelector: ProductSelecting = RandomProductSelector()
    ) {
        self.endpoint = endpoint ?? APIEndpoint(
            baseURL: URL(string: "https://api.hm.com")!,
            path: "/search-services/v1/sv_se/search/resultpage",
            queryItems: [
                URLQueryItem(name: "touchPoint", value: "ios"),
                URLQueryItem(name: "query", value: "jeans"),
                URLQueryItem(name: "page", value: "1")
            ]
        )
        self.httpClient = httpClient
        self.responseDecoder = responseDecoder
        self.productSelector = productSelector
    }

    public func randomProduct() async throws -> Product {
        let request = try endpoint.urlRequest()
        let data = try await httpClient.data(for: request)
        let products = try responseDecoder.decodeProducts(from: data)

        guard let product = productSelector.selectProduct(from: products) else {
            throw ProductClientError.noProducts
        }

        return product
    }
}
