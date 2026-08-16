import ProductClient

struct StubProductFetcher: ProductFetching {
    let product: Product

    func randomProduct() async throws -> Product {
        product
    }
}
