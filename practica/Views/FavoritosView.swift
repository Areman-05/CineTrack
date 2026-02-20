import SwiftUI

/// Pantalla de Favoritos: lista de películas/series guardadas por el usuario.
/// Cumple requisito de pantalla Favoritos del prototipo. CRUD: ver y eliminar.
/// Compatible con iOS 14.4.
struct FavoritosView: View {
    @EnvironmentObject private var viewModel: MovieViewModel

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                if viewModel.favoriteMovies.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 56))
                            .foregroundColor(AppTheme.textTertiary)
                        Text("No tienes favoritos")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.textPrimary)
                        Text("Marca como favorito en Inicio para verlos aquí.")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.favoriteMovies) { movie in
                            NavigationLink(destination: DetailView(movie: movie)) {
                                MovieCardView(movie: movie, viewModel: viewModel, showFavorite: false, showWatchStatus: true)
                            }
                            .listRowBackground(AppTheme.background)
                            .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                        }
                        .onDelete(perform: eliminarFavorito)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Favoritos")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func eliminarFavorito(at offsets: IndexSet) {
        let favoritos = viewModel.favoriteMovies
        for index in offsets where index < favoritos.count {
            viewModel.removeFromList(movieId: favoritos[index].id)
        }
    }
}

#if DEBUG
struct FavoritosView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritosView()
            .environmentObject(MovieViewModel())
    }
}
#endif
