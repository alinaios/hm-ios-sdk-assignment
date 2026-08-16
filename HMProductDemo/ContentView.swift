import ProductClient
import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var viewModel: ProductViewModel

    init(viewModel: ProductViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("H&M Product")
                .navigationBarTitleDisplayMode(.inline)
                .task {
                    await viewModel.loadProduct()
                }
                .toolbar {
                    Button("New Product") {
                        Task {
                            await viewModel.loadProduct()
                        }
                    }
                    .accessibilityIdentifier("newProductButton")
                    .accessibilityLabel("Load a new random product")
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading product")
                .accessibilityIdentifier("loadingView")
                .accessibilityLabel("Loading product")

        case .loaded(let product, let image):
            LoadedProductView(
                product: product,
                image: image,
                displayModeTitle: viewModel.displayModeTitle
            )

        case .failed(let message):
            ProductLoadingErrorView(message: message) {
                Task {
                    await viewModel.loadProduct()
                }
            }
        }
    }
}

private struct LoadedProductView: View {
    let product: Product
    let image: UIImage
    let displayModeTitle: String

    var body: some View {
        VStack(spacing: 20) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 460)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .accessibilityIdentifier("productImage")
                .accessibilityLabel("Product image for \(product.name)")

            Text(product.name)
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
                .accessibilityIdentifier("productName")

            Text(displayModeTitle)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("displayMode")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

private struct ProductLoadingErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Unable to load product")
                .font(.headline)
                .accessibilityIdentifier("errorTitle")

            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("errorMessage")

            Button("Try Again", action: retry)
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("retryButton")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    ContentView(
        viewModel: ProductViewModel(
            productImageLoader: ProductImageLoader(
                productFetcher: PreviewProductFetcher(),
                imageLoader: PreviewImageLoader(),
                imageProcessor: LiveImageProcessor()
            )
        )
    )
}
