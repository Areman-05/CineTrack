import SwiftUI

/// Vista de búsqueda de películas con filtros
/// Permite buscar y filtrar películas por género y puntuación
struct BuscarView: View {
    @EnvironmentObject private var viewModel: MovieViewModel
    @State private var searchText = ""
    @State private var showFilters = false
    @State private var minRating: Double = 7.5
    @State private var selectedGenres: Set<String> = []
    
    private let genres = ["Sci-Fi", "Acción", "Drama", "Terror", "Comedia", "Misterio", "Docu", "Anime"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Search Bar
                    searchBar
                    
                    // Filter Chips
                    filterChips
                    
                    // Results
                    if viewModel.isLoading {
                        Spacer()
                        ActivityIndicator(color: .yellow)
                        Spacer()
                    } else {
                        movieGrid
                    }
                }
                
                // Filter Sheet
                if showFilters {
                    filterSheet
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Buscar películas")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "bell")
                    .foregroundColor(.yellow)
            }
        }
        .padding()
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Buscar...", text: $searchText)
                .foregroundColor(.white)
                .onChange(of: searchText) { value in
                    viewModel.searchMovies(query: value)
                }
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "film")
                        Text("Género")
                    }
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.yellow)
                    .cornerRadius(20)
                }
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "calendar")
                        Text("Fecha")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(20)
                }
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "star")
                        Text("Rating")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(20)
                }
                
                Button(action: { withAnimation { showFilters.toggle() } }) {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text("Filtros")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(20)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
    }
    
    private var movieGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(filteredMovies) { movie in
                    NavigationLink(destination: DetailView(movie: movie).environmentObject(viewModel)) {
                        gridMovieCard(movie: movie)
                    }
                }
            }
            .padding()
        }
    }
    
    private func gridMovieCard(movie: Movie) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImageView(url: movie.posterURL)
                .aspectRatio(contentMode: .fill)
                .frame(height: 240)
                .cornerRadius(12)
                .clipped()
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
                .lineLimit(2)
            
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                Text(String(format: "%.1f", movie.voteAverage))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var filterSheet: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showFilters = false
                    }
                }
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 24) {
                    // Handle
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray)
                        .frame(width: 40, height: 5)
                        .padding(.top, 12)
                    
                    // Header
                    HStack {
                        Text("FILTRAR POR...")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            minRating = 7.5
                            selectedGenres.removeAll()
                        }) {
                            Text("LIMPIAR TODO")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Rating Slider
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("PUNTUACIÓN MÍNIMA")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text("\(String(format: "%.1f", minRating)) / 10")
                                .font(.headline)
                                .foregroundColor(.yellow)
                        }
                        
                        HStack {
                            Text("0")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Slider(value: $minRating, in: 0...10, step: 0.5)
                                .accentColor(.yellow)
                            
                            Text("10")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Genres
                    VStack(alignment: .leading, spacing: 12) {
                        Text("GÉNEROS")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(genres, id: \.self) { genre in
                                Button(action: {
                                    if selectedGenres.contains(genre) {
                                        selectedGenres.remove(genre)
                                    } else {
                                        selectedGenres.insert(genre)
                                    }
                                }) {
                                    Text(genre)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(selectedGenres.contains(genre) ? .black : .white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(selectedGenres.contains(genre) ? Color.yellow : Color.gray.opacity(0.3))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Apply Button
                    Button(action: {
                        withAnimation {
                            showFilters = false
                        }
                    }) {
                        Text("VER RESULTADOS (\(filteredMovies.count))")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.yellow)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
                .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                .cornerRadius(20, corners: [.topLeft, .topRight])
            }
        }
    }
    
    private var filteredMovies: [Movie] {
        viewModel.movies.filter { movie in
            movie.voteAverage >= minRating
        }
    }
}

// Extension para esquinas específicas
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#if DEBUG
struct BuscarView_Previews: PreviewProvider {
    static var previews: some View {
        BuscarView()
            .environmentObject(MovieViewModel())
    }
}
#endif
