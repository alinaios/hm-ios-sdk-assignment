import Foundation

public struct APIEndpoint: Equatable, Sendable {
    private let baseURL: URL
    private let path: String
    private let queryItems: [URLQueryItem]

    public init(
        baseURL: URL,
        path: String,
        queryItems: [URLQueryItem] = []
    ) {
        self.baseURL = baseURL
        self.path = path
        self.queryItems = queryItems
    }

    public func urlRequest() throws -> URLRequest {
        var components = URLComponents(
            url: baseURL.appending(path: path),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components?.url else {
            throw ProductClientError.invalidURL
        }

        return URLRequest(url: url)
    }
}
