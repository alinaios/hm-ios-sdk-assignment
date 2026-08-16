import Foundation
import Testing
@testable import ProductClient

struct APIEndpointTests {
    @Test
    func buildsRequestFromBaseURLPathAndQueryItems() throws {
        let endpoint = APIEndpoint(
            baseURL: URL(string: "https://api.hm.com")!,
            path: "/search-services/v1/sv_se/search/resultpage",
            queryItems: [
                URLQueryItem(name: "touchPoint", value: "ios"),
                URLQueryItem(name: "query", value: "skinny jeans"),
                URLQueryItem(name: "page", value: "1")
            ]
        )

        let request = try endpoint.urlRequest()
        let url = try #require(request.url)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))

        #expect(components.scheme == "https")
        #expect(components.host == "api.hm.com")
        #expect(components.path == "/search-services/v1/sv_se/search/resultpage")
        #expect(components.queryItems == [
            URLQueryItem(name: "touchPoint", value: "ios"),
            URLQueryItem(name: "query", value: "skinny jeans"),
            URLQueryItem(name: "page", value: "1")
        ])
    }

    @Test
    func preservesFullURLWhenInitializedWithURL() throws {
        let url = URL(string: "https://example.com/products?query=jeans&page=2")!
        let endpoint = APIEndpoint(url: url)

        let request = try endpoint.urlRequest()

        #expect(request.url == url)
    }
}
