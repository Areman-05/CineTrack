import SwiftUI

struct ListaDetailView: View {
    let list: FavoriteList
    @EnvironmentObject var viewModel: MovieViewModel
    @State private var showAddSheet = false

    var peliculasEnLista: [Movie] {
        viewModel.moviesInList(list.id)
    }

    var body: some View {
        Group {
            if peliculasEnLista.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.system(size: 44))
                        .foregroundColor(.secondary)
                    Text("Lista vacía")
                        .font(.headline)
                    Text("Añade películas desde el botón +.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(peliculasEnLista) { movie in
                        NavigationLink(destination: DetailView(movie: movie)) {
                            MovieCardView(movie: movie)
                        }
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            let movie = peliculasEnLista[index]
                            viewModel.removeMovieFromList(movieId: movie.id, listId: list.id)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle(list.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddSheet = true }) {
                    Image(systemName: "plus")
                }
                .disabled(viewModel.todasLasPeliculas.isEmpty)
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddToListSheet(listId: list.id)
        }
    }
}

struct AddToListSheet: View {
    let listId: UUID
    @EnvironmentObject var viewModel: MovieViewModel
    @Environment(\.presentationMode) var presentationMode

    var disponibles: [Movie] {
        guard let list = viewModel.favoriteLists.first(where: { $0.id == listId }) else {
            return viewModel.todasLasPeliculas
        }
        let ids = Set(list.movieIds)
        return viewModel.todasLasPeliculas.filter { !ids.contains($0.id) }
    }

    var body: some View {
        NavigationView {
            Group {
                if disponibles.isEmpty {
                    Text("Todas las películas disponibles ya están en esta lista.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(disponibles) { movie in
                        Button(action: {
                            viewModel.addMovieToList(movieId: movie.id, listId: listId, movie: movie)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Text(movie.title)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.blue)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Añadir a lista")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
    }
}

struct ListaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ListaDetailView(list: FavoriteList(name: "Pendientes"))
                .environmentObject(MovieViewModel())
        }
    }
}
