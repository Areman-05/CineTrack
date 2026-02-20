import SwiftUI

/// Vista de una lista/grupo de favoritos: películas de la lista y opción de añadir.
/// Compatible con iOS 14.4.
struct ListaDetailView: View {
    let list: FavoriteList
    @EnvironmentObject private var viewModel: MovieViewModel
    @Environment(\.presentationMode) private var presentationMode
    @State private var showAddSheet = false

    private var listMovies: [Movie] {
        viewModel.movies(in: list.id)
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if listMovies.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "tray")
                                .font(.system(size: 44))
                                .foregroundColor(AppTheme.textTertiary)
                            Text("Añade películas desde Favoritos")
                                .font(AppTheme.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 48)
                    } else {
                        ForEach(listMovies) { movie in
                            HStack(spacing: 0) {
                                NavigationLink(destination: DetailView(movie: movie)) {
                                    MovieCardView(movie: movie, viewModel: viewModel, showFavorite: false, showWatchStatus: true, large: true)
                                }
                                .buttonStyle(PlainButtonStyle())
                                Button(action: { viewModel.removeMovieFromList(movieId: movie.id, listId: list.id) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(AppTheme.textTertiary)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.leading, 8)
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.vertical, 16)
            }
        }
        .navigationTitle(list.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddSheet = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(AppTheme.accent)
                }
                .disabled(viewModel.favoriteMovies.isEmpty)
            }
        })
        .sheet(isPresented: $showAddSheet) {
            AddToListSheet(listId: list.id, viewModel: viewModel)
        }
    }
}

/// Sheet para elegir una película favorita y añadirla a la lista.
struct AddToListSheet: View {
    let listId: UUID
    @ObservedObject var viewModel: MovieViewModel
    @Environment(\.presentationMode) private var presentationMode

    private var list: FavoriteList? {
        viewModel.favoriteLists.first { $0.id == listId }
    }

    private var favoritosNoEnLista: [Movie] {
        guard let list = list else { return viewModel.favoriteMovies }
        let ids = Set(list.movieIds)
        return viewModel.favoriteMovies.filter { !ids.contains($0.id) }
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                if favoritosNoEnLista.isEmpty {
                    Text("Todas tus favoritas ya están en esta lista")
                        .font(AppTheme.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    List {
                        ForEach(favoritosNoEnLista) { movie in
                            Button(action: {
                                viewModel.addMovieToList(movieId: movie.id, listId: listId)
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack {
                                    Text(movie.title)
                                        .font(AppTheme.body)
                                        .foregroundColor(AppTheme.textPrimary)
                                    Spacer()
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(AppTheme.accent)
                                }
                            }
                            .listRowBackground(AppTheme.surface)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Añadir a lista")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppTheme.accent)
                }
            })
        }
    }
}

#if DEBUG
struct ListaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ListaDetailView(list: FavoriteList(name: "Pendientes"))
                .environmentObject(MovieViewModel())
        }
    }
}
#endif
