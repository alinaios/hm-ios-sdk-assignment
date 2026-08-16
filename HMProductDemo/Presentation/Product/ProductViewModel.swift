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
    @Published private(set) var displayModeTitle = AppString.displayModeOriginal.localized

    private let productImageLoader: ProductImageLoading
    private let errorMessageMapper: ErrorMessageMapping
    private var originalImage: UIImage?
    private var processedImage: UIImage?
    private var loadedProduct: Product?
    private var isShowingProcessedImage = false
    private var switchTask: Task<Void, Never>?

    init(
        productImageLoader: ProductImageLoading,
        errorMessageMapper: ErrorMessageMapping = ProductErrorMessageMapper()
    ) {
        self.productImageLoader = productImageLoader
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
            let productImage = try await productImageLoader.loadProductImage()

            originalImage = productImage.originalImage
            processedImage = productImage.processedImage
            loadedProduct = productImage.product
            isShowingProcessedImage = false
            displayModeTitle = AppString.displayModeOriginal.localized
            state = .loaded(productImage.product, productImage.originalImage)
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
        displayModeTitle = isShowingProcessedImage
            ? AppString.displayModeProcessed.localized
            : AppString.displayModeOriginal.localized
        state = .loaded(product, isShowingProcessedImage ? processedImage : originalImage)
    }

    private func breakSwitching() {
        switchTask?.cancel()
        switchTask = nil
    }
}
