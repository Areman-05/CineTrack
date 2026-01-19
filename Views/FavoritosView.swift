import SwiftUI

/// Vista de biblioteca personal (Favoritos)
/// Muestra las películas guardadas por el usuario con diferentes estados
struct FavoritosView: View {
    @EnvironmentObject private var viewModel: MovieViewModel
    @State private var searchText = ""
    @State private var selectedFilter = "Favoritos"
    
    private let filters = ["Recientes", "Películas", "Series", "Favoritos"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Search Bar
                    searchBar
                    
                    // Filter Tabs
                    filterTabs
                    
                    // Content Filters
                    contentFilters
                    
                    // Movie List
                    movieList
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Mi Biblioteca")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("GESTIÓN DE CONTENIDO")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.white)
                    .font(.title3)
            }
        }
        .padding()
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Buscar en mi colección...", text: $searchText)
                .foregroundColor(.white)
            
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
    
    private var filterTabs: some View {
        HStack(spacing: 0) {
            Button(action: { selectedFilter = "Favoritos" }) {
                Text("Favoritos")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(selectedFilter == "Favoritos" ? .black : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selectedFilter == "Favoritos" ? Color.yellow : Color.clear)
                    .cornerRadius(8)
            }
            
            Button(action: { selectedFilter = "Toda mi lista" }) {
                Text("Toda mi lista")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(selectedFilter == "Toda mi lista" ? .black : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selectedFilter == "Toda mi lista" ? Color.yellow : Color.clear)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var contentFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(filters, id: \.self) { filter in
                    Button(action: {}) {
                        HStack {
                            if filter == "Recientes" {
                                Image(systemName: "arrow.up.arrow.down")
                            }
                            Text(filter)
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(20)
                    }
                }
                
                Button(action: {}) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(20)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    private var movieList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.favoriteMovies) { movie in
                    NavigationLink(destination: DetailView(movie: movie)) {
                        favoriteMovieCard(movie: movie)
                    }
                }
            }
            .padding()
        }
    }
    
    private func favoriteMovieCard(movie: Movie) -> some View {
        HStack(spacing: 16) {
            // Poster
            AsyncImage(url: movie.posterURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 100, height: 140)
            .cornerRadius(8)
            .overlay(
                VStack {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .padding(4)
                        Spacer()
                    }
                    Spacer()
                }
            )
            
            // Info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("VISTO")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(4)
                    
                    Text("PELÍCULA")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                }
                
                Text(movie.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text("Denis Villeneuve")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("'Obra maestra visual, ver en...")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .italic()
                    .lineLimit(1)
                
                Spacer()
            }
            
            Spacer()
            
            // Actions
            VStack(spacing: 16) {
                Button(action: {}) {
                    Image(systemName: "list.bullet")
                        .foregroundColor(.yellow)
                }
                
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    FavoritosView()
        .environmentObject(MovieViewModel())
}
