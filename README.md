# HMProductDemo

A small SwiftUI iOS app for the H&M iOS SDK Engineer assignment. The app fetches one random jeans product, displays its name and image, processes the image through a local XCFramework, and alternates between the original and processed image every second.

The toolbar includes a `New Product` action so reviewers can trigger another random product fetch without restarting the app.

## Requirements

- Xcode 26.6 or later
- Swift 6
- iOS 26 simulator or device

## Build and Run

1. Open `HMProductDemo.xcodeproj`.
2. Select the `HMProductDemo` scheme.
3. Run on an iOS 26 simulator.

The app uses the live H&M endpoint from the assignment:

`https://api.hm.com/search-services/v1/sv_se/search/resultpage?touchPoint=ios&query=jeans&page=1`

## Architecture

- `HMProductDemo`: SwiftUI app target. Owns presentation, loading state, image downloading, and one-second image switching.
- `Packages/ProductClient`: Local Swift Package. Owns the H&M API request, HTTP response validation, response decoding, product filtering, and random selection.
- `Frameworks/ImageProcessor.xcframework`: Local binary XCFramework embedded by the app. Owns image processing and applies a red mask at 50% opacity.
- `Frameworks/ImageProcessorSource`: Source used to build the local XCFramework.

The app depends on abstractions for product fetching, image loading, and image processing. Inside `ProductClient`, request execution (`HTTPClient`), response decoding (`ProductResponseDecoder`), and random selection (`ProductSelecting`) are separated so the networking layer can be tested without the UI or live network.

## Testing

Run tests from Xcode with `Command-U`, or from Terminal:

```sh
xcodebuild test -scheme HMProductDemo -destination 'platform=iOS Simulator,name=iPhone 17'
swift test --package-path Packages/ProductClient
cd Frameworks/ImageProcessorSource && xcodebuild test -scheme ImageProcessor -destination 'platform=iOS Simulator,name=iPhone 17'
```

The unit tests cover product decoding, API error handling, image processing, and the view model loading states. The UI test launches with sample data so it does not depend on network availability.

## Accessibility

The loading, image, product name, mode label, error, and retry controls include accessibility labels or identifiers. The product image label includes the product name.

## Known Limitations and Trade-offs

- The product endpoint is live, so the app depends on network availability and the current H&M API response shape.
- Image downloading remains in the app because the assignment only delegates product fetching to the Swift Package.
- The XCFramework source is included for review, but the app links the built local binary framework.
