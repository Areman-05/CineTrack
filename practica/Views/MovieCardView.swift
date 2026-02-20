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
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)

                Text("\(movie.releaseYear) · \(movie.mediaType?.displayName ?? "Película")")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", movie.voteAverage))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: {
                    viewModel.toggleFavorite(movie: movie)
                }) {
                    Image(systemName: viewModel.isFavorite(movieId: movie.id) ? "heart.fill" : "heart")
                        .foregroundColor(viewModel.isFavorite(movieId: movie.id) ? .red : .gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
