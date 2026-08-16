import Foundation

public struct APIEndpoint: Equatable, Sendable {
    private let url: URL?
    private let baseURL: URL
    private let path: String
    private let queryItems: [URLQueryItem]

    public init(url: URL) {
        self.url = url
        self.baseURL = url
        self.path = ""
        self.queryItems = []
    }

    public init(
        baseURL: URL,
        path: String,
        queryItems: [URLQueryItem] = []
    ) {
        self.url = nil
        self.baseURL = baseURL
        self.path = path
        self.queryItems = queryItems
    }

    public func urlRequest() throws -> URLRequest {
        if let url {
            return URLRequest(url: url)
        }

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
