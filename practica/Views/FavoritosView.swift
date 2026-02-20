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
                                FavoritoRowView(movie: movie, viewModel: viewModel)
                            }
                            .listRowBackground(AppTheme.surface)
                            .foregroundColor(AppTheme.textPrimary)
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

/// Fila de un favorito: título, tipo (Película/Serie), puntuación y estado de visualización.
struct FavoritoRowView: View {
    let movie: Movie
    @ObservedObject var viewModel: MovieViewModel

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(2)
                HStack(spacing: 8) {
                    Text(movie.mediaType?.displayName ?? "Película")
                        .font(.caption)
                        .foregroundColor(AppTheme.accent)
                    Text("·")
                        .foregroundColor(AppTheme.textTertiary)
                    Text(viewModel.watchStatus(for: movie.id).displayName)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundColor(AppTheme.accent)
                Text(String(format: "%.1f", movie.voteAverage))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding(.vertical, 8)
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
