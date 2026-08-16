import Foundation

struct ProductErrorMessageMapper: ErrorMessageMapping {
    func message(for error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .cannotFindHost, .cannotConnectToHost:
                return String(localized: "No internet connection. Check your connection and try again.")
            default:
                break
            }
        }

        return String(localized: "Something went wrong while loading the product. Please try again.")
    }
}
