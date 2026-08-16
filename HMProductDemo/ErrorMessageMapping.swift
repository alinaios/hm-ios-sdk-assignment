import Foundation

@MainActor
protocol ErrorMessageMapping {
    func message(for error: Error) -> String
}
