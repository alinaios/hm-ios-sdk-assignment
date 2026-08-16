import Foundation

@MainActor
protocol ImageDataLoading {
    func data(from url: URL) async throws -> (Data, URLResponse)
}
