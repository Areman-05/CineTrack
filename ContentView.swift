import SwiftUI

/// Vista principal que contiene la navegación por tabs
/// Implementa el patrón MVVM con @StateObject y @EnvironmentObject
struct ContentView: View {
    @StateObject private var viewModel = MovieViewModel()
    
    var body: some View {
        TabView {
            ExplorarView()
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }
                .environmentObject(viewModel)
            
            BuscarView()
                .tabItem {
                    Label("Explorar", systemImage: "magnifyingglass")
                }
                .environmentObject(viewModel)
            
            FavoritosView()
                .tabItem {
                    Label("Mi Lista", systemImage: "bookmark.fill")
                }
                .environmentObject(viewModel)
        }
        .accentColor(.yellow)
    }
}

#Preview {
    ContentView()
}

Showing Recent Messages
Build input files cannot be found: '/Users/alumne/Documents/CineTrack6/CineTrack/CineTrackApp.swift', '/Users/alumne/Documents/CineTrack6/CineTrack/Models/Models/Movie.swift', '/Users/alumne/Documents/CineTrack6/CineTrack/Services/Services/TMDBService.swift', '/Users/alumne/Documents/CineTrack6/CineTrack/ContentView.swift', '/Users/alumne/Documents/CineTrack6/CineTrack/Models/Models/UserPreference.swift', '/Users/alumne/Documents/CineTrack6/CineTrack/Views/Views/BuscarView.swift', '/Users/alumne/Documents/CineTrack6/CineTrack/Views/Views/DetailView.swift', '/Users/alumne/Documents/CineTrack6/CineTrack/ViewModels/ViewModels/MovieViewModel.swift', '/Users/alumne/Documents/CineTrack6/CineTrack/Views/Views/FavoritosView.swift', '/Users/alumne/Documents/CineTrack6/CineTrack/Views/Views/ExplorarView.swift'

