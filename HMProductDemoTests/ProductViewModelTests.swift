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
            productImageLoader: StubProductImageLoader(
                productImage: ProductImage(
                    product: product,
                    originalImage: image,
                    processedImage: processedImage
                )
            )
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
            productImageLoader: FailingProductImageLoader()
        )

        await viewModel.loadProduct()

        guard case .failed = viewModel.state else {
            return XCTFail("Expected failed state")
        }
    }

    func testLoadProductPublishesOfflineMessageWhenNetworkIsUnavailable() async {
        let viewModel = ProductViewModel(
            productImageLoader: FailingProductImageLoader(error: URLError(.notConnectedToInternet))
        )

        await viewModel.loadProduct()

        guard case .failed(let message) = viewModel.state else {
            return XCTFail("Expected failed state")
        }

        XCTAssertEqual(message, "No internet connection. Check your connection and try again.")
    }

    func testLoadProductUsesInjectedErrorMessageMapper() async {
        let viewModel = ProductViewModel(
            productImageLoader: FailingProductImageLoader(error: URLError(.timedOut)),
            errorMessageMapper: StubErrorMessageMapper(message: "Custom failure")
        )

        await viewModel.loadProduct()

        guard case .failed(let message) = viewModel.state else {
            return XCTFail("Expected failed state")
        }

        XCTAssertEqual(message, "Custom failure")
    }

    func testRemoteImageLoaderRejectsInvalidImageData() async {
        let loader = RemoteImageLoader(
            dataLoader: StubImageDataLoader(
                data: Data("not image data".utf8),
                response: HTTPURLResponse(
                    url: URL(string: "https://example.com/image.jpg")!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
            )
        )

        do {
            _ = try await loader.image(from: URL(string: "https://example.com/image.jpg")!)
            XCTFail("Expected invalid data error")
        } catch ImageLoadingError.invalidData {
            return
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
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
            productImageLoader: SequencedProductImageLoader(
                productImages: [
                    ProductImage(
                        product: firstProduct,
                        originalImage: solidColorImage(.blue, size: CGSize(width: 10, height: 10)),
                        processedImage: solidColorImage(.red, size: CGSize(width: 10, height: 10))
                    ),
                    ProductImage(
                        product: secondProduct,
                        originalImage: solidColorImage(.blue, size: CGSize(width: 10, height: 10)),
                        processedImage: solidColorImage(.red, size: CGSize(width: 10, height: 10))
                    )
                ]
            )
        )

        await viewModel.loadProduct()
        await viewModel.loadProduct()

        guard case .loaded(let loadedProduct, _) = viewModel.state else {
            return XCTFail("Expected loaded state")
        }

        XCTAssertEqual(loadedProduct, secondProduct)
        XCTAssertEqual(viewModel.displayModeTitle, "Original image")
    }

    func testProductImageLoaderFetchesImageAndProcessesIt() async throws {
        let product = Product(
            id: "1",
            name: "Test Jeans",
            imageURL: URL(string: "https://example.com/image.jpg")!
        )
        let image = solidColorImage(.blue, size: CGSize(width: 10, height: 10))
        let processedImage = solidColorImage(.red, size: CGSize(width: 10, height: 10))
        let loader = ProductImageLoader(
            productFetcher: StubProductFetcher(product: product),
            imageLoader: StubImageLoader(image: image),
            imageProcessor: StubImageProcessor(image: processedImage)
        )

        let productImage = try await loader.loadProductImage()

        XCTAssertEqual(productImage.product, product)
        XCTAssertEqual(productImage.originalImage.pngData(), image.pngData())
        XCTAssertEqual(productImage.processedImage.pngData(), processedImage.pngData())
    }
}

@MainActor
private struct StubProductImageLoader: ProductImageLoading {
    let productImage: ProductImage

    func loadProductImage() async throws -> ProductImage {
        productImage
    }
}

@MainActor
private struct FailingProductImageLoader: ProductImageLoading {
    let error: Error

    init(error: Error = URLError(.notConnectedToInternet)) {
        self.error = error
    }

    func loadProductImage() async throws -> ProductImage {
        throw error
    }
}

@MainActor
private final class SequencedProductImageLoader: ProductImageLoading {
    private let productImages: [ProductImage]
    private var index = 0

    init(productImages: [ProductImage]) {
        self.productImages = productImages
    }

    func loadProductImage() async throws -> ProductImage {
        let productImage = productImages[min(index, productImages.count - 1)]
        index += 1
        return productImage
    }
}

private struct StubProductFetcher: ProductFetching {
    let product: Product

    func randomProduct() async throws -> Product {
        product
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

@MainActor
private struct StubErrorMessageMapper: ErrorMessageMapping {
    let message: String

    func message(for error: Error) -> String {
        message
    }
}

@MainActor
private struct StubImageDataLoader: ImageDataLoading {
    let data: Data
    let response: URLResponse

    func data(from url: URL) async throws -> (Data, URLResponse) {
        (data, response)
    }
}
