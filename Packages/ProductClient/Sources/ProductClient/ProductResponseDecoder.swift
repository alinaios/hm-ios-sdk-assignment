import Foundation

public struct ProductResponseDecoder: Sendable {
    private let decoder: JSONDecoder

    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

    public func decodeProducts(from data: Data) throws -> [Product] {
        let response = try decoder.decode(SearchResponse.self, from: data)

        return response.searchHits.productList.compactMap { item in
            guard !item.id.isEmpty,
                  !item.productName.isEmpty,
                  let url = URL(string: item.productImage),
                  ["http", "https"].contains(url.scheme?.lowercased()) else {
                return nil
            }

            return Product(id: item.id, name: item.productName, imageURL: url)
        }
    }
}

private struct SearchResponse: Decodable {
    let searchHits: SearchHits
}

private struct SearchHits: Decodable {
    let productList: [ProductListItem]
}

private struct ProductListItem: Decodable {
    let id: String
    let productName: String
    let productImage: String
}
