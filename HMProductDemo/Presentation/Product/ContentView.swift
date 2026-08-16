import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: ProductViewModel

    init(viewModel: ProductViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(Text(AppString.productNavigationTitle.resource))
                .navigationBarTitleDisplayMode(.inline)
                .task {
                    await viewModel.loadProduct()
                }
                .toolbar {
                    Button {
                        Task {
                            await viewModel.loadProduct()
                        }
                    } label: {
                        Text(AppString.newProduct.resource)
                    }
                    .accessibilityIdentifier("newProductButton")
                    .accessibilityLabel(Text(AppString.newProductAccessibilityLabel.resource))
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView {
                Text(AppString.loadingProduct.resource)
            }
                .accessibilityIdentifier("loadingView")
                .accessibilityLabel(Text(AppString.loadingProduct.resource))

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
            productImageLoader: SampleProductImageLoader()
        )
    )
}
