import SwiftUI

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
