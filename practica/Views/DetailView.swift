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
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Tipo: Película o Serie (requisito distinguir movie/serie)
                Text(movie.mediaType?.displayName ?? "Película")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .cornerRadius(4)

                Text(movie.title)
                    .font(.title2)
                    .fontWeight(.bold)

                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", movie.voteAverage))
                    Text("·")
                    Text(movie.releaseYear)
                    Spacer()
                }
                .font(.subheadline)
                .foregroundColor(.secondary)

                if !movie.overview.isEmpty {
                    Text(movie.overview)
                        .font(.body)
                        .foregroundColor(.primary)
                }

                // Botón favorito (requisito: marcar como favorito)
                Button(action: {
                    viewModel.toggleFavorite(movieId: movie.id)
                }) {
                    HStack {
                        Image(systemName: viewModel.isFavorite(movieId: movie.id) ? "heart.fill" : "heart")
                        Text(viewModel.isFavorite(movieId: movie.id) ? "Quitar de Favoritos" : "Añadir a Favoritos")
                    }
                    .foregroundColor(viewModel.isFavorite(movieId: movie.id) ? .red : .blue)
                }
                .buttonStyle(PlainButtonStyle())

                // Estado: previsto ver / viendo / visto (requisito profesora)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Estado")
                        .font(.subheadline)
                        .fontWeight(.semibold)
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

                // Nota personal (requisito: personalNote)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nota personal")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    TextField("Escribe una nota...", text: $notaPersonal)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: notaPersonal, perform: { newValue in
                            viewModel.updatePersonalNote(movieId: movie.id, note: newValue)
                        })
                }

                // Eliminar de mi lista (CRUD: eliminar)
                Button(action: {
                    viewModel.removeFromList(movieId: movie.id)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Quitar de mi lista")
                    }
                    .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
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
