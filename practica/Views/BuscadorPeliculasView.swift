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
            ZStack {
                AppTheme.background.ignoresSafeArea()

                VStack(spacing: 20) {
                    // Barra de búsqueda
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppTheme.textSecondary)
                            .font(.body)
                        TextField("Buscar por título...", text: $searchText)
                            .foregroundColor(AppTheme.textPrimary)
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                    }
                    .padding(14)
                    .background(AppTheme.surface)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)

                    // Filtros en tarjeta
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Filtros")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.textSecondary)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Puntuación mínima: \(String(format: "%.1f", minRating))")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                            Slider(value: $minRating, in: 0...10, step: 0.5)
                                .accentColor(AppTheme.accent)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Género")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                            Picker("Género", selection: $selectedGenreId) {
                                Text("Todos").tag(nil as Int?)
                                ForEach(viewModel.genres) { g in
                                    Text(g.name).tag(g.id as Int?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .foregroundColor(AppTheme.textPrimary)
                        }
                    }
                    .padding(16)
                    .background(AppTheme.surface)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)

                    // Botón Buscar
                    Button(action: aplicarFiltros) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("Buscar")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(Color.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.accent)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 16)

                    // Lista de resultados
                    if viewModel.isLoading {
                        Spacer()
                        VStack(spacing: 12) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.accent))
                                .scaleEffect(1.2)
                            Text("Cargando...")
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                    } else if let error = viewModel.errorMessage {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "wifi.exclamationmark")
                                .font(.system(size: 44))
                                .foregroundColor(AppTheme.error)
                            Text(error)
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        Spacer()
                    } else if viewModel.movies.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "film")
                                .font(.system(size: 44))
                                .foregroundColor(AppTheme.textTertiary)
                            Text("Usa los filtros y pulsa Buscar")
                                .foregroundColor(AppTheme.textSecondary)
                                .font(.subheadline)
                            Text("o escribe un título para buscar.")
                                .foregroundColor(AppTheme.textTertiary)
                                .font(.caption)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(viewModel.movies) { movie in
                                NavigationLink(destination: DetailView(movie: movie)) {
                                    FilaPeliculaView(movie: movie, viewModel: viewModel)
                                }
                                .listRowBackground(AppTheme.surface)
                                .foregroundColor(AppTheme.textPrimary)
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .padding(.top, 8)
            }
            .navigationTitle("Buscador")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.loadGenres()
                aplicarFiltros()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func aplicarFiltros() {
        let rating = minRating > 0 ? minRating : nil
        let ids = selectedGenreId.map { [$0] }
        viewModel.searchWithFilters(query: searchText.trimmingCharacters(in: .whitespacesAndNewlines), minRating: rating, genreIds: ids)
    }
}

/// Fila de película/serie en el listado: título, tipo, favorito, puntuación.
private struct FilaPeliculaView: View {
    let movie: Movie
    @ObservedObject var viewModel: MovieViewModel

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(2)
                Text(movie.mediaType?.displayName ?? "Pelicula")
                    .font(.caption)
                    .foregroundColor(AppTheme.accent)
            }
            Spacer()
            Button(action: {
                viewModel.toggleFavorite(movieId: movie.id)
            }) {
                Image(systemName: viewModel.isFavorite(movieId: movie.id) ? "heart.fill" : "heart")
                    .font(.system(size: 18))
                    .foregroundColor(viewModel.isFavorite(movieId: movie.id) ? AppTheme.favorite : AppTheme.textTertiary)
            }
            .buttonStyle(PlainButtonStyle())
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundColor(AppTheme.accent)
                Text(String(format: "%.1f", movie.voteAverage))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(width: 32, alignment: .trailing)
            }
        }
        .padding(.vertical, 6)
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
