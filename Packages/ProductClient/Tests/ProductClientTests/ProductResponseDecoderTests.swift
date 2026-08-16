import Foundation
import Testing
@testable import ProductClient

struct ProductResponseDecoderTests {
    @Test
    func decodesProductsFromSearchHits() throws {
        let data = Data("""
        {
          "searchHits": {
            "productList": [
              {
                "id": "1323075003",
                "productName": "Baggy Regular Waist Jeans",
                "productImage": "https://image.hm.com/product.jpg"
              }
            ]
          }
        }
        """.utf8)

        let products = try ProductResponseDecoder().decodeProducts(from: data)

        #expect(products == [
            Product(
                id: "1323075003",
                name: "Baggy Regular Waist Jeans",
                imageURL: URL(string: "https://image.hm.com/product.jpg")!
            )
        ])
    }

    @Test
    func filtersProductsWithInvalidImageURLs() throws {
        let data = Data("""
        {
          "searchHits": {
            "productList": [
              {
                "id": "1",
                "productName": "Valid Jeans",
                "productImage": "https://image.hm.com/product.jpg"
              },
              {
                "id": "2",
                "productName": "Invalid Jeans",
                "productImage": ""
              }
            ]
          }
        }
        """.utf8)

        let products = try ProductResponseDecoder().decodeProducts(from: data)

        #expect(products.map(\.id) == ["1"])
    }
}
