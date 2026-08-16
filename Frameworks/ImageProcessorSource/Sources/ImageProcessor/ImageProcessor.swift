import UIKit

@MainActor
public struct RedMaskImageProcessor {
    public init() {}

    public func applyRedMask(to image: UIImage, opacity: CGFloat = 0.5) -> UIImage {
        let clampedOpacity = min(max(opacity, 0), 1)
        let size = image.size
        let rect = CGRect(origin: .zero, size: size)
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = image.cgImage?.alphaInfo == .noneSkipLast
            || image.cgImage?.alphaInfo == .noneSkipFirst
            || image.cgImage?.alphaInfo == CGImageAlphaInfo.none

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            image.draw(in: rect, blendMode: .normal, alpha: 1)

            context.cgContext.saveGState()
            context.cgContext.setBlendMode(.normal)
            context.cgContext.setAlpha(clampedOpacity)
            UIColor.red.setFill()
            context.cgContext.fill(rect)
            context.cgContext.restoreGState()
        }
    }
}
