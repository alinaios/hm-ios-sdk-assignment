public protocol ProductSelecting: Sendable {
    func selectProduct(from products: [Product]) -> Product?
}

public struct RandomProductSelector: ProductSelecting {
    public init() {}

    public func selectProduct(from products: [Product]) -> Product? {
        products.randomElement()
    }
}
