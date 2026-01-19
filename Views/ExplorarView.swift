import SwiftUI

/// Vista principal de exploración de películas
/// Muestra películas trending y estrenos recientes
struct ExplorarView: View {
    @EnvironmentObject private var viewModel: MovieViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        headerView
                        
                        // Tabs: Películas / Series
                        tabSelector
                        
                        // Featured Movie
                        if let firstMovie = viewModel.movies.first {
                            featuredMovieCard(movie: firstMovie)
                        }
                        
                        // Trending Global
                        sectionView(title: "TRENDING GLOBAL", movies: Array(viewModel.movies.prefix(4)))
                        
                        // Estrenos Recientes
                        sectionView(title: "ESTRENOS RECIENTES", movies: Array(viewModel.movies.dropFirst(4).prefix(4)))
                    }
                    .padding(.bottom, 100)
                }
            }
            .onAppear {
                viewModel.loadPopularMovies()
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Image(systemName: "crown.fill")
                .foregroundColor(.yellow)
            Text("CinePro")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white)
            }
            
            Button(action: {}) {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.yellow)
            }
        }
        .padding()
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            Button(action: { selectedTab = 0 }) {
                Text("Películas")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(selectedTab == 0 ? .white : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selectedTab == 0 ? Color.gray.opacity(0.3) : Color.clear)
                    .cornerRadius(8)
            }
            
            Button(action: { selectedTab = 1 }) {
                Text("Series")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(selectedTab == 1 ? .white : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selectedTab == 1 ? Color.gray.opacity(0.3) : Color.clear)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }
    
    private func featuredMovieCard(movie: Movie) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            URLImage(url: movie.posterURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(height: 400)
            .cornerRadius(12)
            .overlay(
                VStack(alignment: .leading) {
                    Spacer()
                    
                    HStack {
                        Text("MOVIE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .cornerRadius(4)
                        
                        Text("● TRENDING NOW")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    
                    Text(movie.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Sci-Fi • Action • \(movie.releaseYear)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 12) {
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Watch Trailer")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.yellow)
                            .cornerRadius(8)
                        }
                        
                        Button(action: {
                            viewModel.toggleFavorite(movieId: movie.id)
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                , alignment: .bottomLeading
            )
        }
        .padding(.horizontal)
    }
    
    private func sectionView(title: String, movies: [Movie]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.yellow)
                
                Spacer()
                
                Button(action: {}) {
                    Text("Ver todo")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(movies) { movie in
                        NavigationLink(destination: DetailView(movie: movie)) {
                            movieCard(movie: movie)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func movieCard(movie: Movie) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            URLImage(url: movie.posterURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 140, height: 200)
            .cornerRadius(8)
            .overlay(
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            viewModel.toggleFavorite(movieId: movie.id)
                        }) {
                            Image(systemName: viewModel.isFavorite(movieId: movie.id) ? "bookmark.fill" : "bookmark")
                                .foregroundColor(.yellow)
                                .padding(8)
                        }
                    }
                    Spacer()
                }
            )
            
            Text(movie.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(1)
            
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                Text(String(format: "%.1f", movie.voteAverage))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 140)
    }
}

}

struct ExplorarView_Previews: PreviewProvider {
    static var previews: some View {
        ExplorarView()
            .environmentObject(MovieViewModel())
    }
}
