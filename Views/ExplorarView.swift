import SwiftUI

// MARK: - Explorar View
struct ExplorarView: View {
    @EnvironmentObject var viewModel: MovieViewModel
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.movies.isEmpty {
                    ProgressView("Cargando películas...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.movies.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "film")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No se encontraron películas")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Intenta nuevamente más tarde")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.movies) { movie in
                                NavigationLink(destination: DetailView(movie: movie, viewModel: viewModel)) {
                                    MovieCard(movie: movie, isFavorite: viewModel.isFavorite(movieId: movie.id))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Explorar")
            .task {
                viewModel.loadPopularMovies()
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .onChange(of: viewModel.errorMessage) { newValue in
                if newValue != nil {
                    showingAlert = true
                }
            }
        }
    }
}

// MARK: - Movie Card
struct MovieCard: View {
    let movie: Movie
    let isFavorite: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: movie.posterURL) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 90)
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 90)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 60, height: 90)
            .cornerRadius(8)
            .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    Text(movie.releaseYear)
                    Text("•")
                        .foregroundColor(.secondary)
                    Text("Película")
                        .foregroundColor(.secondary)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    StarRatingView(rating: movie.voteAverage / 2.0)
                    Text(String(format: "%.1f", movie.voteAverage))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Star Rating View
struct StarRatingView: View {
    let rating: Double
    let maxRating: Int = 5
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<maxRating, id: \.self) { index in
                Image(systemName: starImage(for: index))
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
        }
    }
    
    private func starImage(for index: Int) -> String {
        let value = rating - Double(index)
        if value >= 1.0 {
            return "star.fill"
        } else if value >= 0.5 {
            return "star.lefthalf.fill"
        } else {
            return "star"
        }
    }
}

#Preview {
    ExplorarView()
        .environmentObject(MovieViewModel())
}
