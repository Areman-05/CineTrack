import SwiftUI

/// Vista de búsqueda con filtros por título, puntuación mínima y género.
/// Todo el contenido es scrollable. Compatible con iOS 14.4.
struct BuscadorPeliculasView: View {
    @EnvironmentObject private var viewModel: MovieViewModel
    @State private var searchText = ""
    @State private var minRating: Double = 0
    @State private var selectedGenreId: Int?

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Barra de búsqueda
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(AppTheme.textSecondary)
                                .font(AppTheme.body)
                            TextField("Buscar por título...", text: $searchText)
                                .font(AppTheme.body)
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

                        // Filtros compactos
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Filtros")
                                .font(AppTheme.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(AppTheme.textTertiary)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Puntuación mínima: \(String(format: "%.1f", minRating))")
                                    .font(AppTheme.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                                Slider(value: $minRating, in: 0...10, step: 0.5)
                                    .accentColor(AppTheme.accent)
                            }

                            HStack(alignment: .center) {
                                Text("Género")
                                    .font(AppTheme.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                                Spacer(minLength: 8)
                                Picker("", selection: $selectedGenreId) {
                                    Text("Todos").tag(nil as Int?)
                                    ForEach(viewModel.genres) { g in
                                        Text(g.name).tag(g.id as Int?)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .accentColor(AppTheme.accent)
                                .frame(maxWidth: 140)
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
                                    .font(AppTheme.subheadline)
                                Text("Buscar")
                                    .font(AppTheme.headline)
                            }
                            .foregroundColor(Color(red: 0.12, green: 0.10, blue: 0.04))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.accent)
                            .cornerRadius(AppTheme.cardCornerRadius)
                        }
                        .padding(.horizontal, 16)
                        .buttonStyle(PlainButtonStyle())

                        // Resultados (todo en el mismo scroll)
                        resultadosSection
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
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

    @ViewBuilder
    private var resultadosSection: some View {
        if viewModel.isLoading {
            VStack(spacing: 12) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.accent))
                    .scaleEffect(1.2)
                Text("Cargando...")
                    .font(AppTheme.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
        } else if let error = viewModel.errorMessage {
            VStack(spacing: 12) {
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 44))
                    .foregroundColor(AppTheme.error)
                Text(error)
                    .font(AppTheme.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
        } else if viewModel.movies.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "film")
                    .font(.system(size: 44))
                    .foregroundColor(AppTheme.textTertiary)
                Text("Usa los filtros y pulsa Buscar")
                    .font(AppTheme.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                Text("o escribe un título para buscar.")
                    .font(AppTheme.caption)
                    .foregroundColor(AppTheme.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("Resultados")
                    .font(AppTheme.headline)
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(.horizontal, 16)

                ForEach(viewModel.movies) { movie in
                    NavigationLink(destination: DetailView(movie: movie)) {
                        MovieCardView(movie: movie, viewModel: viewModel, showFavorite: true, showWatchStatus: false, large: true)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 16)
                }
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
