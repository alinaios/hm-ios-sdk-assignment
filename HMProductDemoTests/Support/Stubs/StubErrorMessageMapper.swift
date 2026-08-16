import Foundation
@testable import HMProductDemo

@MainActor
struct StubErrorMessageMapper: ErrorMessageMapping {
    let message: String

    func message(for error: Error) -> String {
        message
    }
}
