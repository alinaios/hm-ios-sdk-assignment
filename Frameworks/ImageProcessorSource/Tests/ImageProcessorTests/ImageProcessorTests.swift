import Testing
import UIKit
@testable import ImageProcessor

@MainActor
struct ImageProcessorTests {
    @Test
    func appliesRedMaskToImage() {
        let image = solidColorImage(.blue, size: CGSize(width: 8, height: 8))

        let processed = RedMaskImageProcessor().applyRedMask(to: image)

        #expect(processed.size == image.size)
        #expect(processed.pngData() != image.pngData())

        let pixel = processed.rgbaPixel(at: CGPoint(x: 4, y: 4))
        #expect(pixel.red > 120)
        #expect(pixel.blue > 120)
        #expect(pixel.green < 40)
    }
}

private func solidColorImage(_ color: UIColor, size: CGSize) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { context in
        color.setFill()
        context.fill(CGRect(origin: .zero, size: size))
    }
}

private extension UIImage {
    func rgbaPixel(at point: CGPoint) -> (red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        guard let cgImage else {
            return (0, 0, 0, 0)
        }

        let width = cgImage.width
        let height = cgImage.height
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return (0, 0, 0, 0)
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        let x = min(max(Int(point.x), 0), width - 1)
        let y = min(max(Int(point.y), 0), height - 1)
        let index = (y * width + x) * 4
        return (pixels[index], pixels[index + 1], pixels[index + 2], pixels[index + 3])
    }
}
