import Foundation

struct URLSessionImageDataLoader: ImageDataLoading {
    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await urlSession.data(from: url)
    }
}
