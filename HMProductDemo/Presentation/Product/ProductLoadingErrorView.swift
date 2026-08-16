import SwiftUI

struct ProductLoadingErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(AppString.unableToLoadProduct.resource)
                .font(.headline)
                .accessibilityIdentifier("errorTitle")

            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("errorMessage")

            Button(action: retry) {
                Text(AppString.retry.resource)
            }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("retryButton")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
    }
}
