import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            BuscadorPeliculasView()
                .tabItem {
                    Label("Inicio", systemImage: "magnifyingglass")
                }
            ExplorarView()
                .tabItem {
                    Label("Explorar", systemImage: "square.grid.2x2")
                }
            FavoritosView()
                .tabItem {
                    Label("Favoritos", systemImage: "heart.fill")
                }
            PerfilView()
                .tabItem {
                    Label("Perfil", systemImage: "person.circle.fill")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MovieViewModel())
            .environmentObject(UserProfileStore())
    }
}
