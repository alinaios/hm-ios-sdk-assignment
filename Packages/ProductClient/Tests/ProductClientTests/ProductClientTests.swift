import Foundation
import Testing
@testable import ProductClient

struct ProductClientTests {
    @Test
    func throwsWhenResponseIsNotSuccessful() async throws {
        let client = HMBrowseProductClient(
            httpClient: FailingHTTPClient(error: ProductClientError.invalidResponse)
        )

        await #expect(throws: ProductClientError.invalidResponse) {
            _ = try await client.randomProduct()
        }
    }

    @Test
    func returnsRandomProductFromSuccessfulResponse() async throws {
        let data = Data("""
        {
          "searchHits": {
            "productList": [
              {
                "id": "1",
                "productName": "Slim Jeans",
                "productImage": "https://image.hm.com/product.jpg"
              }
            ]
          }
        }
        """.utf8)
        let selectedProduct = Product(
            id: "1",
            name: "Slim Jeans",
            imageURL: URL(string: "https://image.hm.com/product.jpg")!
        )
        let client = HMBrowseProductClient(
            httpClient: StubHTTPClient(data: data),
            productSelector: StubProductSelector(product: selectedProduct)
        )

        let product = try await client.randomProduct()

        #expect(product.name == "Slim Jeans")
    }

    @Test
    func sendsRequestToConfiguredEndpoint() async throws {
        let endpoint = URL(string: "https://example.com/products")!
        let httpClient = RecordingHTTPClient(data: Data("""
        {
          "searchHits": {
            "productList": [
              {
                "id": "1",
                "productName": "Slim Jeans",
                "productImage": "https://image.hm.com/product.jpg"
              }
            ]
          }
        }
        """.utf8))
        let client = HMBrowseProductClient(endpoint: endpoint, httpClient: httpClient)

        _ = try await client.randomProduct()

        let requestedURL = await httpClient.requestedURL
        #expect(requestedURL == endpoint)
    }
}

private struct StubHTTPClient: HTTPClient {
    let data: Data

    func data(for request: URLRequest) async throws -> Data {
        data
    }
}

private struct FailingHTTPClient: HTTPClient {
    let error: ProductClientError

    func data(for request: URLRequest) async throws -> Data {
        throw error
    }
}

private struct StubProductSelector: ProductSelecting {
    let product: Product?

    func selectProduct(from products: [Product]) -> Product? {
        product
    }
}

private actor RecordingHTTPClient: HTTPClient {
    private let data: Data
    private(set) var requestedURL: URL?

    init(data: Data) {
        self.data = data
    }

    func data(for request: URLRequest) async throws -> Data {
        requestedURL = request.url
        return data
    }
}
