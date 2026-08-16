import ProductClient
import XCTest
@testable import HMProductDemo

@MainActor
final class ProductViewModelTests: XCTestCase {
    func testLoadProductPublishesLoadedState() async throws {
        let product = Product(
            id: "1",
            name: "Test Jeans",
            imageURL: URL(string: "https://example.com/image.jpg")!
        )
        let image = solidColorImage(.blue, size: CGSize(width: 10, height: 10))
        let processedImage = solidColorImage(.red, size: CGSize(width: 10, height: 10))
        let viewModel = ProductViewModel(
            productFetcher: StubProductFetcher(product: product),
            imageLoader: StubImageLoader(image: image),
            imageProcessor: StubImageProcessor(image: processedImage)
        )

        await viewModel.loadProduct()

        guard case .loaded(let loadedProduct, let loadedImage) = viewModel.state else {
            return XCTFail("Expected loaded state")
        }

        XCTAssertEqual(loadedProduct, product)
        XCTAssertEqual(loadedImage.pngData(), image.pngData())
        XCTAssertEqual(viewModel.displayModeTitle, "Original image")
    }

    func testLoadProductPublishesFailureState() async {
        let viewModel = ProductViewModel(
            productFetcher: FailingProductFetcher(),
            imageLoader: StubImageLoader(image: UIImage()),
            imageProcessor: StubImageProcessor(image: UIImage())
        )

        await viewModel.loadProduct()

        guard case .failed = viewModel.state else {
            return XCTFail("Expected failed state")
        }
    }

    func testLoadProductPublishesOfflineMessageWhenNetworkIsUnavailable() async {
        let viewModel = ProductViewModel(
            productFetcher: FailingProductFetcher(error: URLError(.notConnectedToInternet)),
            imageLoader: StubImageLoader(image: UIImage()),
            imageProcessor: StubImageProcessor(image: UIImage())
        )

        await viewModel.loadProduct()

        guard case .failed(let message) = viewModel.state else {
            return XCTFail("Expected failed state")
        }

        XCTAssertEqual(message, "No internet connection. Check your connection and try again.")
    }

    func testLoadProductCanReplaceCurrentProduct() async throws {
        let firstProduct = Product(
            id: "1",
            name: "First Jeans",
            imageURL: URL(string: "https://example.com/first.jpg")!
        )
        let secondProduct = Product(
            id: "2",
            name: "Second Jeans",
            imageURL: URL(string: "https://example.com/second.jpg")!
        )
        let viewModel = ProductViewModel(
            productFetcher: SequencedProductFetcher(products: [firstProduct, secondProduct]),
            imageLoader: StubImageLoader(image: solidColorImage(.blue, size: CGSize(width: 10, height: 10))),
            imageProcessor: StubImageProcessor(image: solidColorImage(.red, size: CGSize(width: 10, height: 10)))
        )

        await viewModel.loadProduct()
        await viewModel.loadProduct()

        guard case .loaded(let loadedProduct, _) = viewModel.state else {
            return XCTFail("Expected loaded state")
        }

        XCTAssertEqual(loadedProduct, secondProduct)
        XCTAssertEqual(viewModel.displayModeTitle, "Original image")
    }
}

private struct StubProductFetcher: ProductFetching {
    let product: Product

    func randomProduct() async throws -> Product {
        product
    }
}

private struct FailingProductFetcher: ProductFetching {
    let error: Error

    init(error: Error = URLError(.notConnectedToInternet)) {
        self.error = error
    }

    func randomProduct() async throws -> Product {
        throw error
    }
}

private actor SequencedProductFetcher: ProductFetching {
    private let products: [Product]
    private var index = 0

    init(products: [Product]) {
        self.products = products
    }

    func randomProduct() async throws -> Product {
        let product = products[min(index, products.count - 1)]
        index += 1
        return product
    }
}

@MainActor
private struct StubImageLoader: ImageLoading {
    let image: UIImage

    func image(from url: URL) async throws -> UIImage {
        image
    }
}

@MainActor
private struct StubImageProcessor: AppImageProcessing {
    let image: UIImage

    func process(_ image: UIImage) -> UIImage {
        self.image
    }
}
