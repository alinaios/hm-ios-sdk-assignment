import Foundation
@testable import HMProductDemo

@MainActor
struct StubImageDataLoader: ImageDataLoading {
    let data: Data
    let response: URLResponse

    func data(from url: URL) async throws -> (Data, URLResponse) {
        (data, response)
    }
}
