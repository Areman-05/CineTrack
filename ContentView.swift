import SwiftUI

// Content View
struct ContentView: View {
    @StateObject private var viewModel = MovieViewModel()
    
    var body: some View {
        TabView {
            ExplorarView()
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }
            
            FavoritosView()
                .tabItem {
                    Label("Favoritos", systemImage: "heart")
                }
            
            BuscarView()
                .tabItem {
                    Label("Buscar", systemImage: "magnifyingglass")
                }
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    ContentView()
}
