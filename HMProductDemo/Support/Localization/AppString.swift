import Foundation

enum AppString {
    case displayModeOriginal
    case displayModeProcessed
    case genericProductLoadingError
    case loadingProduct
    case newProduct
    case newProductAccessibilityLabel
    case noInternetConnectionError
    case productNavigationTitle
    case productImageAccessibilityLabelFormat
    case retry
    case sampleProductName
    case unableToLoadProduct

    var resource: LocalizedStringResource {
        switch self {
        case .displayModeOriginal:
            LocalizedStringResource("Original image")
        case .displayModeProcessed:
            LocalizedStringResource("Processed image")
        case .genericProductLoadingError:
            LocalizedStringResource("Something went wrong while loading the product. Please try again.")
        case .loadingProduct:
            LocalizedStringResource("Loading product")
        case .newProduct:
            LocalizedStringResource("New Product")
        case .newProductAccessibilityLabel:
            LocalizedStringResource("Load a new random product")
        case .noInternetConnectionError:
            LocalizedStringResource("No internet connection. Check your connection and try again.")
        case .productNavigationTitle:
            LocalizedStringResource("H&M Product")
        case .productImageAccessibilityLabelFormat:
            LocalizedStringResource("Product image for %@")
        case .retry:
            LocalizedStringResource("Try Again")
        case .sampleProductName:
            LocalizedStringResource("Sample H&M Jeans")
        case .unableToLoadProduct:
            LocalizedStringResource("Unable to load product")
        }
    }

    var localized: String {
        String(localized: resource)
    }
}
