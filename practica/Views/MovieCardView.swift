import SwiftUI

/// Tarjeta de película/serie con póster, título, año • tipo, puntuación y opcional favorito/estado.
/// Diseño inspirado en apps de cine; reutilizable en Buscador y Favoritos.
/// Compatible con iOS 14.4.
struct MovieCardView: View {
    let movie: Movie
    var viewModel: MovieViewModel?
    var showFavorite: Bool = false
    var showWatchStatus: Bool = false
    /// true = tarjeta más grande (póster y texto).
    var large: Bool = false

    private var posterWidth: CGFloat { large ? 100 : 72 }
    private var posterHeight: CGFloat { large ? 150 : 108 }

    private var subtitle: String {
        var parts = [movie.releaseYear, movie.mediaType?.displayName ?? "Película"]
        if showWatchStatus, let vm = viewModel {
            parts.append(vm.watchStatus(for: movie.id).displayName)
        }
        return parts.joined(separator: " • ")
    }

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.cardSpacing) {
            AsyncImageView(url: movie.posterURL)
                .aspectRatio(2/3, contentMode: .fill)
                .frame(width: posterWidth, height: posterHeight)
                .clipped()
                .cornerRadius(AppTheme.posterCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.posterCornerRadius)
                        .stroke(AppTheme.divider, lineWidth: 0.5)
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title)
                    .font(large ? AppTheme.headline : AppTheme.subheadline)
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(subtitle)
                    .font(AppTheme.caption)
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(large ? .caption : .caption2)
                        .foregroundColor(AppTheme.accent)
                    Text(String(format: "%.1f", movie.voteAverage))
                        .font(AppTheme.captionMedium)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if showFavorite, let vm = viewModel {
                Button(action: { vm.toggleFavorite(movieId: movie.id) }) {
                    Image(systemName: vm.isFavorite(movieId: movie.id) ? "heart.fill" : "heart")
                        .font(.system(size: large ? 20 : 18))
                        .foregroundColor(vm.isFavorite(movieId: movie.id) ? AppTheme.favorite : AppTheme.textTertiary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(large ? 16 : AppTheme.cardPadding)
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
