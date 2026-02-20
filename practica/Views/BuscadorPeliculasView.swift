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

                VStack(spacing: 16) {
                    // Barra de búsqueda
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppTheme.textSecondary)
                            .font(.body)
                        TextField("Buscar por título...", text: $searchText)
                            .foregroundColor(AppTheme.textPrimary)
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(AppTheme.textTertiary)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(AppTheme.surface)
                    .cornerRadius(AppTheme.cardCornerRadius)
                    .padding(.horizontal, 16)

                    // Filtros en tarjeta
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Filtros")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.textTertiary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Puntuación mínima: \(String(format: "%.1f", minRating))")
                                .font(.caption2)
                                .foregroundColor(AppTheme.textSecondary)
                            Slider(value: $minRating, in: 0...10, step: 0.5)
                                .accentColor(AppTheme.accent)
                        }

                        HStack {
                            Text("Género")
                                .font(.caption2)
                                .foregroundColor(AppTheme.textSecondary)
                            Spacer()
                            Picker("Género", selection: $selectedGenreId) {
                                Text("Todos").tag(nil as Int?)
                                ForEach(viewModel.genres) { g in
                                    Text(g.name).tag(g.id as Int?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .foregroundColor(AppTheme.textPrimary)
                            .accentColor(AppTheme.accent)
                        }
                    }
                    .padding(AppTheme.cardPadding)
                    .background(AppTheme.surface)
                    .cornerRadius(AppTheme.cardCornerRadius)
                    .padding(.horizontal, 16)

                    // Botón Buscar
                    Button(action: aplicarFiltros) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.subheadline)
                            Text("Buscar")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(Color(red: 0.12, green: 0.10, blue: 0.04))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.accent)
                        .cornerRadius(AppTheme.cardCornerRadius)
                    }
                    .padding(.horizontal, 16)
                    .buttonStyle(PlainButtonStyle())

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
                                    MovieCardView(movie: movie, viewModel: viewModel, showFavorite: true, showWatchStatus: false)
                                }
                                .listRowBackground(AppTheme.background)
                                .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
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

#if DEBUG
struct BuscadorPeliculasView_Previews: PreviewProvider {
    static var previews: some View {
        BuscadorPeliculasView()
            .environmentObject(MovieViewModel())
    }
}
#endif
