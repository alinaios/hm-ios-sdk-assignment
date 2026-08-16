import Foundation

struct ProductErrorMessageMapper: ErrorMessageMapping {
    func message(for error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .cannotFindHost, .cannotConnectToHost, .timedOut:
                return AppString.noInternetConnectionError.localized
            default:
                break
            }
        }

        return AppString.genericProductLoadingError.localized
    }
}
