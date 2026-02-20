import SwiftUI

struct BuscadorPeliculasView: View {
    @EnvironmentObject var viewModel: MovieViewModel
    @State private var searchText = ""
    @State private var minRating: Double = 0
    @State private var selectedGenreId: Int? = nil

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {

                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(AppTheme.textSecondary)
                            TextField("Buscar película...", text: $searchText)
                                .foregroundColor(AppTheme.textPrimary)
                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(AppTheme.textTertiary)
                                }
                            }
                        }
                        .padding(10)
                        .background(AppTheme.surface)
                        .cornerRadius(AppTheme.cardCornerRadius)
                        .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Filtros")
                                .font(AppTheme.caption)
                                .foregroundColor(AppTheme.textTertiary)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Puntuación mínima: \(String(format: "%.1f", minRating))")
                                    .font(AppTheme.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                                Slider(value: $minRating, in: 0...10, step: 0.5)
                                    .accentColor(AppTheme.accent)
                            }

                            HStack {
                                Text("Género")
                                    .font(AppTheme.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                                Spacer()
                                Picker("Género", selection: $selectedGenreId) {
                                    Text("Todos").tag(nil as Int?)
                                    ForEach(viewModel.genres) { genre in
                                        Text(genre.name).tag(genre.id as Int?)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .accentColor(AppTheme.accent)
                            }
                        }
                        .padding(AppTheme.cardPadding)
                        .background(AppTheme.surface)
                        .cornerRadius(AppTheme.cardCornerRadius)
                        .padding(.horizontal)

                        Button(action: buscar) {
                            Text("Buscar")
                                .font(AppTheme.headline)
                                .foregroundColor(Color(red: 0.12, green: 0.10, blue: 0.04))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.accent)
                                .cornerRadius(AppTheme.cardCornerRadius)
                        }
                        .padding(.horizontal)
                        .buttonStyle(PlainButtonStyle())

                        if viewModel.isLoading {
                            ProgressView("Buscando...")
                                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.accent))
                                .padding()
                        } else if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(AppTheme.error)
                                .padding()
                        } else if viewModel.movies.isEmpty {
                            Text("Usa los filtros y pulsa Buscar.")
                                .font(AppTheme.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                                .padding()
                        } else {
                            VStack(spacing: 12) {
                                Text("Resultados")
                                    .font(AppTheme.headline)
                                    .foregroundColor(AppTheme.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)

                                ForEach(viewModel.movies) { movie in
                                    NavigationLink(destination: DetailView(movie: movie)) {
                                        MovieCardView(movie: movie)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Buscador")
            .onAppear {
                viewModel.loadGenres()
                buscar()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func buscar() {
        let generos = selectedGenreId.map { [$0] }
        viewModel.searchMovies(
            query: searchText,
            minRating: minRating > 0 ? minRating : nil,
            genreIds: generos
        )
    }
}

struct BuscadorPeliculasView_Previews: PreviewProvider {
    static var previews: some View {
        BuscadorPeliculasView()
            .environmentObject(MovieViewModel())
    }
}
