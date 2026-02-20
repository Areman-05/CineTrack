import SwiftUI

/// Vista de búsqueda con filtros por título, puntuación mínima y género.
/// Compatible con iOS 14.4.
struct BuscadorPeliculasView: View {
    @EnvironmentObject private var viewModel: MovieViewModel
    @State private var searchText = ""
    @State private var minRating: Double = 0
    @State private var selectedGenreId: Int?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Barra de búsqueda
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Buscar por título...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 8)
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Filtro: puntuación mínima
                VStack(alignment: .leading, spacing: 4) {
                    Text("Puntuación mínima: \(String(format: "%.1f", minRating))")
                        .font(.subheadline)
                    Slider(value: $minRating, in: 0...10, step: 0.5)
                        .padding(.horizontal)
                }
                
                // Filtro: género
                VStack(alignment: .leading, spacing: 4) {
                    Text("Género")
                        .font(.subheadline)
                    Picker("Género", selection: $selectedGenreId) {
                        Text("Todos").tag(nil as Int?)
                        ForEach(viewModel.genres) { g in
                            Text(g.name).tag(g.id as Int?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                .padding(.horizontal)
                
                // Botón aplicar filtros
                Button(action: aplicarFiltros) {
                    Text("Buscar")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Lista de resultados
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Cargando...")
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    Spacer()
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                } else if viewModel.movies.isEmpty {
                    Spacer()
                    Text("Usa los filtros y pulsa Buscar, o escribe un título.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                } else {
                    List(viewModel.movies) { movie in
                        NavigationLink(destination: DetailView(movie: movie)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(movie.title)
                                    Text(movie.mediaType?.displayName ?? "Pelicula")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                Spacer()
                                Button(action: {
                                    viewModel.toggleFavorite(movieId: movie.id)
                                }) {
                                    Image(systemName: viewModel.isFavorite(movieId: movie.id) ? "heart.fill" : "heart")
                                        .foregroundColor(viewModel.isFavorite(movieId: movie.id) ? .red : .gray)
                                }
                                .buttonStyle(PlainButtonStyle())
                                Text(String(format: "%.1f", movie.voteAverage))
                                    .foregroundColor(.gray)
                                    .frame(width: 36, alignment: .trailing)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Buscador")
            .onAppear {
                viewModel.loadGenres()
                aplicarFiltros()
            }
        }
    }
    
    private func aplicarFiltros() {
        let rating = minRating > 0 ? minRating : nil
        let ids = selectedGenreId.map { [$0] }
        viewModel.searchWithFilters(query: searchText.trimmingCharacters(in: .whitespacesAndNewlines), minRating: rating, genreIds: ids)
    }
}

#if DEBUG
struct BuscadorPeliculasView_Previews: PreviewProvider {
    static var previews: some View {
        BuscadorPeliculasView()
            .environmentObject(MovieViewModel())
    }
}
#endif
