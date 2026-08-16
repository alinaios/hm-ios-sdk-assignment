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
    private var imageSwitcher: ProductImageSwitcher?
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
        imageSwitcher = nil
        state = .loading
        do {
            let productImage = try await productImageLoader.loadProductImage()
            let imageSwitcher = ProductImageSwitcher(productImage: productImage)
            let display = imageSwitcher.currentDisplay

            self.imageSwitcher = imageSwitcher
            displayModeTitle = display.displayModeTitle
            state = .loaded(display.product, display.image)
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
        guard var imageSwitcher else {
            return
        }

        let display = imageSwitcher.toggle()
        self.imageSwitcher = imageSwitcher
        displayModeTitle = display.displayModeTitle
        state = .loaded(display.product, display.image)
    }

    private func breakSwitching() {
        switchTask?.cancel()
        switchTask = nil
    }
}
