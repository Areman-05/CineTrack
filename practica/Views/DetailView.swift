import SwiftUI

struct DetailView: View {
    let movie: Movie
    @EnvironmentObject var viewModel: MovieViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var nota = ""
    @State private var estado: WatchStatus = .toWatch

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                AsyncImageView(url: movie.posterURL)
                    .aspectRatio(2/3, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .clipped()
                    .cornerRadius(12)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {

                    Text(movie.title)
                        .font(.title2)
                        .fontWeight(.bold)

                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", movie.voteAverage))
                        Text("·")
                        Text(movie.releaseYear)
                        Text("·")
                        Text(movie.mediaType?.displayName ?? "Película")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                if !movie.overview.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sinopsis")
                            .font(.headline)
                        Text(movie.overview)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                VStack(alignment: .leading, spacing: 16) {

                    Button(action: {
                        viewModel.toggleFavorite(movie: movie)
                    }) {
                        Label(
                            viewModel.isFavorite(movieId: movie.id) ? "Quitar de Favoritos" : "Añadir a Favoritos",
                            systemImage: viewModel.isFavorite(movieId: movie.id) ? "heart.fill" : "heart"
                        )
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .foregroundColor(viewModel.isFavorite(movieId: movie.id) ? .red : .primary)
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Estado")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Picker("Estado", selection: $estado) {
                            ForEach(WatchStatus.allCases, id: \.self) { s in
                                Text(s.displayName).tag(s)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: estado, perform: { newValue in
                            viewModel.setWatchStatus(movieId: movie.id, status: newValue)
                        })
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nota personal")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        TextField("Escribe una nota...", text: $nota)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                            .onChange(of: nota, perform: { newValue in
                                viewModel.updatePersonalNote(movieId: movie.id, note: newValue)
                            })
                    }

                    if !viewModel.favoriteLists.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Mis listas")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            ForEach(viewModel.favoriteLists) { list in
                                Button(action: {
                                    if viewModel.isInList(movieId: movie.id, listId: list.id) {
                                        viewModel.removeMovieFromList(movieId: movie.id, listId: list.id)
                                    } else {
                                        viewModel.addMovieToList(movieId: movie.id, listId: list.id, movie: movie)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: viewModel.isInList(movieId: movie.id, listId: list.id) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(viewModel.isInList(movieId: movie.id, listId: list.id) ? .blue : .secondary)
                                        Text(list.name)
                                            .foregroundColor(.primary)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(10)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(movie.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            nota = viewModel.personalNote(for: movie.id)
            estado = viewModel.watchStatus(for: movie.id)
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailView(movie: Movie(
                id: 1,
                title: "Ejemplo",
                overview: "Una sinopsis de ejemplo para esta película.",
                posterPath: nil,
                voteAverage: 7.5,
                releaseDate: "2024-01-01",
                mediaType: .movie
            ))
            .environmentObject(MovieViewModel())
        }
    }
}
