import SwiftUI

/// Pantalla de Favoritos: todas las favoritas y listas/grupos del usuario.
/// Compatible con iOS 14.4.
struct FavoritosView: View {
    @EnvironmentObject var viewModel: MovieViewModel
    @State private var showNewListSheet = false
    @State private var newListName = ""

    var body: some View {
        NavigationView {
            Group {
                if viewModel.favoriteMovies.isEmpty && viewModel.favoriteLists.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No tienes favoritos")
                            .font(.title3)
                        Text("Añade películas desde Buscador o Explorar.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        if !viewModel.favoriteMovies.isEmpty {
                            Section(header: Text("Todas")) {
                                ForEach(viewModel.favoriteMovies) { movie in
                                    NavigationLink(destination: DetailView(movie: movie)) {
                                        MovieCardView(movie: movie)
                                    }
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
                            Section(header: Text("Mis listas")) {
                                ForEach(viewModel.favoriteLists) { list in
                                    NavigationLink(destination: ListaDetailView(list: list)) {
                                        HStack {
                                            Image(systemName: "folder.fill")
                                                .foregroundColor(.blue)
                                            VStack(alignment: .leading) {
                                                Text(list.name)
                                                    .font(.headline)
                                                Text("\(list.movieIds.count) películas")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding(.vertical, 4)
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
            }
            .navigationTitle("Favoritos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showNewListSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewListSheet) {
                NavigationView {
                    VStack(spacing: 20) {
                        TextField("Nombre de la lista", text: $newListName)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        Spacer()
                    }
                    .padding(.top, 20)
                    .navigationTitle("Nueva lista")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancelar") {
                                newListName = ""
                                showNewListSheet = false
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Crear") {
                                if !newListName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    viewModel.addFavoriteList(name: newListName)
                                    newListName = ""
                                    showNewListSheet = false
                                }
                            }
                            .disabled(newListName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

}

struct FavoritosView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritosView()
            .environmentObject(MovieViewModel())
    }
}
