import ProductClient
import SwiftUI
import UIKit

struct LoadedProductView: View {
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
