import SwiftUI

@main
struct practicaApp: App {
    @StateObject private var viewModel = MovieViewModel()
    @StateObject private var profileStore = UserProfileStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(profileStore)
        }
    }
}
