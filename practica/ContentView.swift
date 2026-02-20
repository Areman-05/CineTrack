import SwiftUI

/// Vista raíz: TabView con Inicio (Buscador) y Favoritos según prototipo.
/// Compatible con iOS 14.4.
struct ContentView: View {
    var body: some View {
        TabView {
            BuscadorPeliculasView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Inicio")
                }
            FavoritosView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favoritos")
                }
        }
        .accentColor(AppTheme.accent)
        .preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MovieViewModel())
    }
}
