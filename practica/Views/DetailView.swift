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
                VStack(alignment: .leading, spacing: 20) {
                    // Tipo: Película o Serie
                    Text(movie.mediaType?.displayName ?? "Película")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(AppTheme.accent)
                        .cornerRadius(6)

                    Text(movie.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)

                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .foregroundColor(AppTheme.accent)
                            .font(.subheadline)
                        Text(String(format: "%.1f", movie.voteAverage))
                            .foregroundColor(AppTheme.textSecondary)
                        Text("·")
                            .foregroundColor(AppTheme.textTertiary)
                        Text(movie.releaseYear)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .font(.subheadline)

                    if !movie.overview.isEmpty {
                        Text(movie.overview)
                            .font(.body)
                            .foregroundColor(AppTheme.textSecondary)
                            .lineSpacing(4)
                    }

                    // Sección: Favorito y estado
                    VStack(alignment: .leading, spacing: 14) {
                        Button(action: {
                            viewModel.toggleFavorite(movieId: movie.id)
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: viewModel.isFavorite(movieId: movie.id) ? "heart.fill" : "heart")
                                    .font(.body)
                                Text(viewModel.isFavorite(movieId: movie.id) ? "Quitar de Favoritos" : "Añadir a Favoritos")
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(viewModel.isFavorite(movieId: movie.id) ? AppTheme.favorite : AppTheme.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(AppTheme.surface)
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Estado")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                            Picker("Estado", selection: $estadoVer) {
                                ForEach(WatchStatus.allCases, id: \.self) { s in
                                    Text(s.displayName).tag(s)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .onChange(of: estadoVer, perform: { newValue in
                                viewModel.setWatchStatus(movieId: movie.id, status: newValue)
                            })
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nota personal")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                            TextField("Escribe una nota...", text: $notaPersonal)
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(12)
                                .background(AppTheme.surface)
                                .cornerRadius(10)
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
                                Text("Quitar de mi lista")
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(AppTheme.error)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(20)
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
