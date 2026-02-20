import SwiftUI

/// Tarjeta de película/serie con póster, título, año • tipo, puntuación y opcional favorito/estado.
/// Diseño inspirado en apps de cine; reutilizable en Buscador y Favoritos.
/// Compatible con iOS 14.4.
struct MovieCardView: View {
    let movie: Movie
    var viewModel: MovieViewModel?
    /// true en Buscador: muestra botón favorito.
    var showFavorite: Bool = false
    /// true en Favoritos: muestra estado (Previsto ver / Viendo / Visto).
    var showWatchStatus: Bool = false

    private var subtitle: String {
        var parts = [movie.releaseYear, movie.mediaType?.displayName ?? "Película"]
        if showWatchStatus, let vm = viewModel {
            parts.append(vm.watchStatus(for: movie.id).displayName)
        }
        return parts.joined(separator: " • ")
    }

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.cardSpacing) {
            // Póster
            AsyncImageView(url: movie.posterURL)
                .aspectRatio(2/3, contentMode: .fill)
                .frame(width: 72, height: 108)
                .clipped()
                .cornerRadius(AppTheme.posterCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.posterCornerRadius)
                        .stroke(AppTheme.divider, lineWidth: 0.5)
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(AppTheme.accent)
                    Text(String(format: "%.1f", movie.voteAverage))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if showFavorite, let vm = viewModel {
                Button(action: { vm.toggleFavorite(movieId: movie.id) }) {
                    Image(systemName: vm.isFavorite(movieId: movie.id) ? "heart.fill" : "heart")
                        .font(.system(size: 18))
                        .foregroundColor(vm.isFavorite(movieId: movie.id) ? AppTheme.favorite : AppTheme.textTertiary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(AppTheme.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surface)
        .cornerRadius(AppTheme.cardCornerRadius)
    }
}

#if DEBUG
struct MovieCardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            VStack {
                MovieCardView(
                    movie: Movie(id: 1, title: "Sin piedad", overview: "", posterPath: nil, voteAverage: 6.8, releaseDate: "2024-01-01", mediaType: .movie),
                    viewModel: nil,
                    showFavorite: true,
                    showWatchStatus: false
                )
                .padding()
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
