import SwiftUI

/// Pantalla de Favoritos: todas las favoritas y listas/grupos del usuario.
/// Compatible con iOS 14.4.
struct FavoritosView: View {
    @EnvironmentObject var viewModel: MovieViewModel
    @State private var showNewListSheet = false
    @State private var newListName = ""

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                favoritosContent
            }
            .navigationTitle("Favoritos")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showNewListSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppTheme.accent)
                    }
                }
            }
            .sheet(isPresented: $showNewListSheet) {
                newListSheet
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    @ViewBuilder
    private var favoritosContent: some View {
        if viewModel.favoriteMovies.isEmpty && viewModel.favoriteLists.isEmpty {
            emptyState
        } else {
            favoritosList
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.slash")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.textTertiary)
            Text("No tienes favoritos")
                .font(AppTheme.titleMedium)
                .foregroundColor(AppTheme.textPrimary)
            Text("Añade películas desde Buscador o Explorar.")
                .font(AppTheme.caption)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var favoritosList: some View {
        List {
            if !viewModel.favoriteMovies.isEmpty {
                Section(header: Text("Todas").font(AppTheme.caption).foregroundColor(AppTheme.textTertiary)) {
                    ForEach(viewModel.favoriteMovies) { movie in
                        NavigationLink(destination: DetailView(movie: movie)) {
                            MovieCardView(movie: movie)
                        }
                        .listRowBackground(AppTheme.background)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            let movie = viewModel.favoriteMovies[index]
                            viewModel.removeFromFavorites(movieId: movie.id)
                        }
                    }
                }
            }

            if !viewModel.favoriteLists.isEmpty {
                Section(header: Text("Mis listas").font(AppTheme.caption).foregroundColor(AppTheme.textTertiary)) {
                    ForEach(viewModel.favoriteLists) { list in
                        NavigationLink(destination: ListaDetailView(list: list)) {
                            listRow(list: list)
                        }
                        .listRowBackground(AppTheme.surface)
                        .contextMenu {
                            Button(action: {
                                viewModel.removeFavoriteList(id: list.id)
                            }) {
                                Label("Eliminar lista", systemImage: "trash")
                            }
                            .foregroundColor(AppTheme.error)
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            viewModel.removeFavoriteList(id: viewModel.favoriteLists[index].id)
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }

    private func listRow(list: FavoriteList) -> some View {
        HStack {
            Image(systemName: "folder.fill")
                .foregroundColor(AppTheme.accent)
            VStack(alignment: .leading) {
                Text(list.name)
                    .font(AppTheme.headline)
                    .foregroundColor(AppTheme.textPrimary)
                Text("\(list.movieIds.count) películas")
                    .font(AppTheme.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var newListSheet: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                VStack(spacing: 20) {
                    TextField("Nombre de la lista", text: $newListName)
                        .font(AppTheme.body)
                        .foregroundColor(AppTheme.textPrimary)
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(AppTheme.cardCornerRadius)
                        .padding(.horizontal)
                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle("Nueva lista")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        newListName = ""
                        showNewListSheet = false
                    }
                    .foregroundColor(AppTheme.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Crear") {
                        if !newListName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            viewModel.addFavoriteList(name: newListName)
                            newListName = ""
                            showNewListSheet = false
                        }
                    }
                    .foregroundColor(AppTheme.accent)
                    .fontWeight(.semibold)
                    .disabled(newListName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

struct FavoritosView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritosView()
            .environmentObject(MovieViewModel())
    }
}
