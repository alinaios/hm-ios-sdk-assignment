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

                Text(viewModel.displayModeTitle)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("displayMode")
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))

        case .failed(let message):
            VStack(spacing: 16) {
                Text("Unable to load product")
                    .font(.headline)
                    .accessibilityIdentifier("errorTitle")

                Text(message)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("errorMessage")

                Button("Try Again") {
                    Task {
                        await viewModel.loadProduct()
                    }
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("retryButton")
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityElement(children: .contain)
        }
    }
}

#Preview {
    ContentView(
        viewModel: ProductViewModel(
            productFetcher: PreviewProductFetcher(),
            imageLoader: PreviewImageLoader(),
            imageProcessor: LiveImageProcessor()
        )
    )
}
