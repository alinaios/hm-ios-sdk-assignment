import ProductClient
import SwiftUI

@main
struct HMProductDemoApp: App {
    private let viewModelFactory = ProductViewModelFactory()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModelFactory.makeDefault())
        }
    }
}
