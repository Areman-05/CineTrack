import SwiftUI

@main
struct practicaApp: App {
    @StateObject private var viewModel = MovieViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
