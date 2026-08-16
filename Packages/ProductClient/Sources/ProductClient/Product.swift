import Foundation

public struct Product: Equatable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let imageURL: URL

    public init(id: String, name: String, imageURL: URL) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
    }
}
