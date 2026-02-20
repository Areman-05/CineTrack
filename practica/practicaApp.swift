import SwiftUI

@main
struct practicaApp: App {
    @StateObject private var viewModel = MovieViewModel()
    @StateObject private var profileStore = UserProfileStore()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashView()
                } else {
                    ContentView()
                }
            }
            .environmentObject(viewModel)
            .environmentObject(profileStore)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showSplash = false
                    }
                }
            }
        }
    }
}
