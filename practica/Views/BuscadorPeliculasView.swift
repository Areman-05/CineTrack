import SwiftUI

struct BuscadorPeliculasView: View {
    @EnvironmentObject var viewModel: MovieViewModel
    @State private var searchText = ""
    @State private var minRating: Double = 0
    @State private var selectedGenreId: Int? = nil

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {

                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Buscar película...", text: $searchText)
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Filtros")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Puntuación mínima: \(String(format: "%.1f", minRating))")
                                .font(.caption)
                            Slider(value: $minRating, in: 0...10, step: 0.5)
                                .accentColor(.blue)
                        }

                        HStack {
                            Text("Género")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Picker("Género", selection: $selectedGenreId) {
                                Text("Todos").tag(nil as Int?)
                                ForEach(viewModel.genres) { genre in
                                    Text(genre.name).tag(genre.id as Int?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    Button(action: buscar) {
                        Text("Buscar")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    if viewModel.isLoading {
                        ProgressView("Buscando...")
                            .padding()
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    } else if viewModel.movies.isEmpty {
                        Text("Usa los filtros y pulsa Buscar.")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        VStack(spacing: 12) {
                            Text("Resultados")
                                .font(.headline)
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
