import Foundation
import UIKit

@MainActor
protocol ImageLoading {
    func image(from url: URL) async throws -> UIImage
}
