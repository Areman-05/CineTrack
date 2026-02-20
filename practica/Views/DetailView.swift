import SwiftUI

struct DetailView: View {
    let movie: Movie
    @EnvironmentObject var viewModel: MovieViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var nota = ""
    @State private var estado: WatchStatus = .toWatch

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    AsyncImageView(url: movie.posterURL)
                        .aspectRatio(2/3, contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 280)
                        .clipped()
                        .cornerRadius(AppTheme.cardCornerRadius)
                        .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {

                    Text(movie.title)
                        .font(AppTheme.titleLarge)
                        .foregroundColor(AppTheme.textPrimary)

                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundColor(AppTheme.accent)
                        Text(String(format: "%.1f", movie.voteAverage))
                        Text("·")
                        Text(movie.releaseYear)
                        Text("·")
                        Text(movie.mediaType?.displayName ?? "Película")
                    }
                    .font(AppTheme.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.horizontal)

                if !movie.overview.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sinopsis")
                            .font(AppTheme.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        Text(movie.overview)
                            .font(AppTheme.body)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(AppTheme.cardPadding)
                    .background(AppTheme.surface)
                    .cornerRadius(AppTheme.cardCornerRadius)
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
                        .background(AppTheme.surface)
                        .foregroundColor(viewModel.isFavorite(movieId: movie.id) ? AppTheme.favorite : AppTheme.textPrimary)
                        .cornerRadius(AppTheme.cardCornerRadius)
                    }
                    .buttonStyle(PlainButtonStyle())

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Estado")
                            .font(AppTheme.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
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
                            .font(AppTheme.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                        TextField("Escribe una nota...", text: $nota)
                            .font(AppTheme.body)
                            .foregroundColor(AppTheme.textPrimary)
                            .padding()
                            .background(AppTheme.surface)
                            .cornerRadius(AppTheme.posterCornerRadius)
                            .onChange(of: nota, perform: { newValue in
                                viewModel.updatePersonalNote(movieId: movie.id, note: newValue)
                            })
                    }

                    if !viewModel.favoriteLists.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Mis listas")
                                .font(AppTheme.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
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
                                            .foregroundColor(viewModel.isInList(movieId: movie.id, listId: list.id) ? AppTheme.accent : AppTheme.textTertiary)
                                        Text(list.name)
                                            .foregroundColor(AppTheme.textPrimary)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(AppTheme.surface)
                                    .cornerRadius(AppTheme.posterCornerRadius)
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
