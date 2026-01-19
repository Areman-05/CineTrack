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

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
