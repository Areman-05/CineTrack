import SwiftUI

/// Vista de detalle de una película/serie.
/// Muestra info, favorito, estado (previsto ver / viendo / visto) y nota personal. CRUD: editar y eliminar.
/// Compatible con iOS 14.4.
struct DetailView: View {
    let movie: Movie
    @EnvironmentObject private var viewModel: MovieViewModel
    @Environment(\.presentationMode) private var presentationMode

    @State private var notaPersonal: String = ""
    @State private var estadoVer: WatchStatus = .toWatch

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // Póster y badge
                    ZStack(alignment: .topLeading) {
                        AsyncImageView(url: movie.posterURL)
                            .aspectRatio(2/3, contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: 280)
                            .clipped()

                        Text(movie.mediaType?.displayName ?? "Película")
                            .font(AppTheme.captionMedium)
                            .foregroundColor(Color(red: 0.15, green: 0.12, blue: 0.02))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(AppTheme.accent)
                            .cornerRadius(6)
                            .padding(12)
                    }
                    .background(AppTheme.surface)
                    .cornerRadius(AppTheme.cardCornerRadius)
                    .padding(.horizontal, 16)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(movie.title)
                            .font(AppTheme.titleLarge)
                            .foregroundColor(AppTheme.textPrimary)

                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .foregroundColor(AppTheme.accent)
                                .font(AppTheme.subheadline)
                            Text(String(format: "%.1f", movie.voteAverage))
                                .foregroundColor(AppTheme.textSecondary)
                            Text("·")
                                .foregroundColor(AppTheme.textTertiary)
                            Text(movie.releaseYear)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .font(AppTheme.subheadline)
                    }
                    .padding(.horizontal, 16)

                    if !movie.overview.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Sinopsis")
                                .font(AppTheme.captionMedium)
                                .foregroundColor(AppTheme.textTertiary)
                            Text(movie.overview)
                                .font(AppTheme.body)
                                .foregroundColor(AppTheme.textSecondary)
                                .lineSpacing(4)
                        }
                        .padding(AppTheme.cardPadding)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.surface)
                        .cornerRadius(AppTheme.cardCornerRadius)
                        .padding(.horizontal, 16)
                    }

                    // Acciones y estado
                    VStack(alignment: .leading, spacing: 14) {
                        Button(action: {
                            viewModel.toggleFavorite(movieId: movie.id)
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: viewModel.isFavorite(movieId: movie.id) ? "heart.fill" : "heart")
                                    .font(AppTheme.body)
                                Text(viewModel.isFavorite(movieId: movie.id) ? "Quitar de Favoritos" : "Añadir a Favoritos")
                                    .font(AppTheme.bodyMedium)
                            }
                            .foregroundColor(viewModel.isFavorite(movieId: movie.id) ? AppTheme.favorite : AppTheme.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(AppTheme.surfaceElevated)
                            .cornerRadius(AppTheme.posterCornerRadius)
                        }
                        .buttonStyle(PlainButtonStyle())

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Estado")
                                .font(AppTheme.caption)
                                .foregroundColor(AppTheme.textSecondary)
                            Picker("Estado", selection: $estadoVer) {
                                ForEach(WatchStatus.allCases, id: \.self) { s in
                                    Text(s.displayName).tag(s)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .accentColor(AppTheme.accent)
                            .onChange(of: estadoVer, perform: { newValue in
                                viewModel.setWatchStatus(movieId: movie.id, status: newValue)
                            })
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nota personal")
                                .font(AppTheme.caption)
                                .foregroundColor(AppTheme.textSecondary)
                            TextField("Escribe una nota...", text: $notaPersonal)
                                .font(AppTheme.body)
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(12)
                                .background(AppTheme.surfaceElevated)
                                .cornerRadius(AppTheme.posterCornerRadius)
                                .onChange(of: notaPersonal, perform: { newValue in
                                    viewModel.updatePersonalNote(movieId: movie.id, note: newValue)
                                })
                        }

                        Button(action: {
                            viewModel.removeFromList(movieId: movie.id)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "trash")
                                    .font(AppTheme.body)
                                Text("Quitar de mi lista")
                                    .font(AppTheme.bodyMedium)
                            }
                            .foregroundColor(AppTheme.error)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(AppTheme.cardPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.surface)
                    .cornerRadius(AppTheme.cardCornerRadius)
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 16)
            }
        }
        .navigationTitle(movie.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            notaPersonal = viewModel.personalNote(for: movie.id)
            estadoVer = viewModel.watchStatus(for: movie.id)
        }
    }
}

#if DEBUG
struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailView(movie: Movie(
                id: 1,
                title: "Ejemplo",
                overview: "Sinopsis.",
                posterPath: nil,
                voteAverage: 7.5,
                releaseDate: "2024-01-01",
                mediaType: .movie
            ))
            .environmentObject(MovieViewModel())
        }
    }
}
#endif
