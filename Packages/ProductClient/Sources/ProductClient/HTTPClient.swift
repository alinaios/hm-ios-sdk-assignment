import Foundation

public protocol HTTPClient: Sendable {
    func data(for request: URLRequest) async throws -> Data
}

public struct URLSessionHTTPClient: HTTPClient {
    private let urlSession: URLSession

    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    public func data(for request: URLRequest) async throws -> Data {
        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw ProductClientError.invalidResponse
        }

        return data
    }
}
