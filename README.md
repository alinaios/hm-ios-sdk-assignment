# HMProductDemo

A small SwiftUI app for the H&M iOS SDK Engineer assignment. It loads a random jeans product, shows the product image, processes that image with a local XCFramework, and switches between the original and processed image every second.

## Build And Run

| Step | Action |
| --- | --- |
| 1 | Open `HMProductDemo.xcodeproj` in Xcode. |
| 2 | Select the `HMProductDemo` scheme. |
| 3 | Run on an iOS 26 simulator or device. |

Requirements: Xcode with iOS 26 support, Swift 6, and network access for the live product API.

## Requirement Coverage

| Assignment item | Where it is handled |
| --- | --- |
| SwiftUI app | `HMProductDemo` app target |
| Swift 6, iOS 26, strict concurrency | Project and package build settings |
| Random product from H&M API | `Packages/ProductClient` |
| Product name and image | SwiftUI product screen |
| Local XCFramework image processing | `Frameworks/ImageProcessor.xcframework` |
| Red mask at 50% opacity | Image processor framework source |
| Original/processed image switching | Product view model, every 1 second |
| Unit and UI tests | App tests, package tests, framework tests |
| Accessibility | Labels and identifiers on key UI elements |

## Architecture

| Area | Responsibility |
| --- | --- |
| App | Presents the screen, handles loading/error states, downloads the image, and wires dependencies together. |
| ProductClient package | Fetches products, builds API requests, decodes the response, and selects one product. |
| ImageProcessor XCFramework | Receives an image, applies the red mask, and returns the processed image. |

The app is intentionally the composition layer. Product API logic stays in the Swift Package, and image-processing logic stays in the XCFramework. This keeps the framework reusable and prevents product/network details from leaking into image processing.

## Testing

| Test area | What it proves |
| --- | --- |
| App unit tests | Loading success, loading failure, offline/timeout errors, image processing flow, and product replacement. |
| ProductClient tests | API request creation, response decoding, error handling, and random product selection. |
| ImageProcessor tests | Red-mask processing behavior. |
| UI test | The main screen renders with sample data without needing the network. |

Run all main app tests:

```sh
xcodebuild test -scheme HMProductDemo -destination 'platform=iOS Simulator,name=iPhone 17'
```

Run package tests:

```sh
swift test --package-path Packages/ProductClient
swift test --package-path Frameworks/ImageProcessorSource
```

## Accessibility

The screen includes accessibility support for loading, product image, product name, image mode, retry, and new-product controls. The UI test also uses stable identifiers for the main product screen elements.

## Notes And Trade-offs

| Topic | Decision |
| --- | --- |
| Live API | The app uses the assignment endpoint, so product loading depends on network availability and the current API response shape. |
| Offline behavior | Network failures and request timeouts show a user-facing error with retry. |
| Image downloading | Kept in the app because the assignment only requires product fetching in the Swift Package. |
| XCFramework source | Included for review, while the app links the local built XCFramework. |
| Extra button | A `New Product` button lets reviewers fetch another random product without restarting the app. |
