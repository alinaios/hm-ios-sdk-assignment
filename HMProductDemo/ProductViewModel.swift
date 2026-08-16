import Foundation
import ProductClient
import SwiftUI
import UIKit

@MainActor
final class ProductViewModel: ObservableObject {
    enum State {
        case idle
        case loading
        case loaded(Product, UIImage)
        case failed(String)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var displayModeTitle = "Original image"

    private let productFetcher: ProductFetching
    private let imageLoader: ImageLoading
    private let imageProcessor: AppImageProcessing
    private let errorMessageMapper: ErrorMessageMapping
    private var originalImage: UIImage?
    private var processedImage: UIImage?
    private var loadedProduct: Product?
    private var isShowingProcessedImage = false
    private var switchTask: Task<Void, Never>?

    init(
        productFetcher: ProductFetching,
        imageLoader: ImageLoading,
        imageProcessor: AppImageProcessing,
        errorMessageMapper: ErrorMessageMapping = ProductErrorMessageMapper()
    ) {
        self.productFetcher = productFetcher
        self.imageLoader = imageLoader
        self.imageProcessor = imageProcessor
        self.errorMessageMapper = errorMessageMapper
    }

    deinit {
        switchTask?.cancel()
    }

    func loadProduct() async {
        if case .loading = state {
            return
        }

        breakSwitching()
        state = .loading
        do {
            let product = try await productFetcher.randomProduct()
            let image = try await imageLoader.image(from: product.imageURL)
            let processedImage = imageProcessor.process(image)

            originalImage = image
            self.processedImage = processedImage
            loadedProduct = product
            isShowingProcessedImage = false
            displayModeTitle = "Original image"
            state = .loaded(product, image)
            startSwitchingImages()
        } catch {
            state = .failed(errorMessageMapper.message(for: error))
        }
    }

    private func startSwitchingImages() {
        switchTask?.cancel()
        switchTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                self?.toggleDisplayedImage()
            }
        }
    }

    private func toggleDisplayedImage() {
        guard let product = loadedProduct,
              let originalImage,
              let processedImage else {
            return
        }

        isShowingProcessedImage.toggle()
        displayModeTitle = isShowingProcessedImage ? "Processed image" : "Original image"
        state = .loaded(product, isShowingProcessedImage ? processedImage : originalImage)
    }

    private func breakSwitching() {
        switchTask?.cancel()
        switchTask = nil
    }
}

@MainActor
protocol ErrorMessageMapping {
    func message(for error: Error) -> String
}

struct ProductErrorMessageMapper: ErrorMessageMapping {
    func message(for error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .cannotFindHost, .cannotConnectToHost:
                return "No internet connection. Check your connection and try again."
            default:
                break
            }
        }

        return "Something went wrong while loading the product. Please try again."
    }
}

@MainActor
struct ProductViewModelFactory {
    func makeDefault() -> ProductViewModel {
        if ProcessInfo.processInfo.environment["UITEST_USE_SAMPLE_DATA"] == "1" {
            return ProductViewModel(
                productFetcher: PreviewProductFetcher(),
                imageLoader: PreviewImageLoader(),
                imageProcessor: LiveImageProcessor()
            )
        }

        return ProductViewModel(
            productFetcher: HMBrowseProductClient(),
            imageLoader: RemoteImageLoader(),
            imageProcessor: LiveImageProcessor()
        )
    }
}
