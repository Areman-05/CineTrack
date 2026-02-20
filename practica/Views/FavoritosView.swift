import SwiftUI

/// Pantalla de Favoritos: todas las favoritas y listas/grupos del usuario.
/// Compatible con iOS 14.4.
struct FavoritosView: View {
    @EnvironmentObject private var viewModel: MovieViewModel
    @State private var showNewListSheet = false
    @State private var newListName = ""

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                if viewModel.favoriteMovies.isEmpty && viewModel.favoriteLists.isEmpty {
                    emptyState
                } else {
                    List {
                        if !viewModel.favoriteMovies.isEmpty {
                            Section(header: sectionHeader("Todas")) {
                                ForEach(viewModel.favoriteMovies) { movie in
                                    NavigationLink(destination: DetailView(movie: movie)) {
                                        MovieCardView(movie: movie, viewModel: viewModel, showFavorite: false, showWatchStatus: true, large: true)
                                    }
                                    .listRowBackground(AppTheme.background)
                                    .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                                    .contextMenu {
                                        if !viewModel.favoriteLists.isEmpty {
                                            ForEach(viewModel.favoriteLists) { list in
                                                Button(action: { viewModel.addMovieToList(movieId: movie.id, listId: list.id) }) {
                                                    Label(list.name, systemImage: "folder")
                                                }
                                            }
                                        }
                                    }
                                }
                                .onDelete(perform: eliminarFavorito)
                            }
                        }

                        if !viewModel.favoriteLists.isEmpty {
                            Section(header: sectionHeader("Mis listas")) {
                                ForEach(viewModel.favoriteLists) { list in
                                    NavigationLink(destination: ListaDetailView(list: list)) {
                                        HStack(spacing: 12) {
                                            Image(systemName: "folder.fill")
                                                .font(.title2)
                                                .foregroundColor(AppTheme.accent)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(list.name)
                                                    .font(AppTheme.headline)
                                                    .foregroundColor(AppTheme.textPrimary)
                                                Text("\(list.movieIds.count) películas")
                                                    .font(AppTheme.caption)
                                                    .foregroundColor(AppTheme.textSecondary)
                                            }
                                            Spacer()
                                        }
                                        .padding(.vertical, 8)
                                    }
                                    .listRowBackground(AppTheme.surface)
                                }
                                .onDelete(perform: eliminarLista)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Favoritos")
            .navigationBarTitleDisplayMode(.large)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showNewListSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppTheme.accent)
                    }
                }
            })
            .sheet(isPresented: $showNewListSheet) {
                NewListSheet(
                    name: $newListName,
                    onCreate: {
                        let name = newListName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !name.isEmpty {
                            viewModel.addFavoriteList(name: name)
                            newListName = ""
                            showNewListSheet = false
                        }
                    },
                    onCancel: { showNewListSheet = false; newListName = "" }
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 56))
                .foregroundColor(AppTheme.textTertiary)
            Text("No tienes favoritos")
                .font(AppTheme.titleMedium)
                .foregroundColor(AppTheme.textPrimary)
            Text("Marca como favorito en Inicio o Explorar, o crea una lista con el botón +.")
                .font(AppTheme.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(AppTheme.caption)
            .fontWeight(.semibold)
            .foregroundColor(AppTheme.textTertiary)
    }

    private func eliminarFavorito(at offsets: IndexSet) {
        let favoritos = viewModel.favoriteMovies
        for index in offsets where index < favoritos.count {
            viewModel.removeFromList(movieId: favoritos[index].id)
        }
    }

    private func eliminarLista(at offsets: IndexSet) {
        for index in offsets where index < viewModel.favoriteLists.count {
            viewModel.removeFavoriteList(id: viewModel.favoriteLists[index].id)
        }
    }
}

/// Sheet para crear una nueva lista de favoritos.
struct NewListSheet: View {
    @Binding var name: String
    var onCreate: () -> Void
    var onCancel: () -> Void

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                VStack(spacing: 20) {
                    TextField("Nombre de la lista", text: $name)
                        .font(AppTheme.body)
                        .foregroundColor(AppTheme.textPrimary)
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(AppTheme.cardCornerRadius)
                        .padding(.horizontal, 20)
                    Spacer()
                }
                .padding(.top, 24)
            }
            .navigationTitle("Nueva lista")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { onCancel() }
                        .foregroundColor(AppTheme.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Crear") { onCreate() }
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.accent)
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            })
        }
    }
}

#if DEBUG
struct FavoritosView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritosView()
            .environmentObject(MovieViewModel())
    }
}
#endif
