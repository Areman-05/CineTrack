import SwiftUI

// MARK: - Detail View
struct DetailView: View {
    let movie: Movie
    @ObservedObject var viewModel: MovieViewModel
    @State private var movieDetail: MovieDetail?
    @State private var isLoading = false
    @Environment(\.dismiss) var dismiss
    
    var isFavorite: Bool {
        viewModel.isFavorite(movieId: movie.id)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    AsyncImage(url: movie.posterURL) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 300)
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 300)
                                .clipped()
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 300)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .font(.title2)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding()
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(movie.title)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            HStack(spacing: 12) {
                                if let genres = movieDetail?.genres, !genres.isEmpty {
                                    Text(genres.first?.name ?? "")
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(20)
                                } else {
                                    Text("Película")
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(20)
                                }
                                
                                Text(movie.releaseYear)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack(spacing: 8) {
                                StarRatingView(rating: movie.voteAverage / 2.0)
                                Text("\(String(format: "%.1f", movie.voteAverage)) / 5.0")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.toggleFavorite(movieId: movie.id)
                        }) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(isFavorite ? .red : .gray)
                        }
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sinopsis")
                            .font(.headline)
                        
                        Text(movie.overview.isEmpty ? "No hay sinopsis disponible." : movie.overview)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .offset(y: -20)
            }
        }
        .navigationBarHidden(true)
        .task {
            loadMovieDetails()
        }
    }
    
    private func loadMovieDetails() {
        isLoading = true
        TMDBService.shared.fetchMovieDetails(id: movie.id) { result in
            Task { @MainActor in
                isLoading = false
                if case .success(let detail) = result {
                    self.movieDetail = detail
                }
            }
        }
    }
}

// MARK: - View Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    NavigationView {
        DetailView(
            movie: Movie(
                id: 1,
                title: "El Laberinto del Destino",
                overview: "Un detective brillante debe resolver una serie de enigmas que lo llevan a cuestionar su propia realidad.",
                posterPath: nil,
                voteAverage: 4.5,
                releaseDate: "2023-01-01"
            ),
            viewModel: MovieViewModel()
        )
    }
}
