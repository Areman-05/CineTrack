import SwiftUI

struct MovieCardView: View {
    let movie: Movie
    @EnvironmentObject var viewModel: MovieViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImageView(url: movie.posterURL)
                .aspectRatio(2/3, contentMode: .fill)
                .frame(width: 80, height: 120)
                .clipped()
                .cornerRadius(AppTheme.posterCornerRadius)

            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title)
                    .font(AppTheme.headline)
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(2)

                Text("\(movie.releaseYear) · \(movie.mediaType?.displayName ?? "Película")")
                    .font(AppTheme.caption)
                    .foregroundColor(AppTheme.textSecondary)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(AppTheme.accent)
                        .font(AppTheme.caption)
                    Text(String(format: "%.1f", movie.voteAverage))
                        .font(AppTheme.captionMedium)
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()

                Button(action: {
                    viewModel.toggleFavorite(movie: movie)
                }) {
                    Image(systemName: viewModel.isFavorite(movieId: movie.id) ? "heart.fill" : "heart")
                        .foregroundColor(viewModel.isFavorite(movieId: movie.id) ? AppTheme.favorite : AppTheme.textTertiary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.surface)
        .cornerRadius(AppTheme.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
