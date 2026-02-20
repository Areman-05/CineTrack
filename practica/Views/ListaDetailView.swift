import SwiftUI

struct ListaDetailView: View {
    let list: FavoriteList
    @EnvironmentObject var viewModel: MovieViewModel
    @State private var showAddSheet = false

    var peliculasEnLista: [Movie] {
        viewModel.moviesInList(list.id)
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            Group {
                if peliculasEnLista.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 44))
                            .foregroundColor(AppTheme.textTertiary)
                        Text("Lista vacía")
                            .font(AppTheme.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        Text("Añade películas desde el botón +.")
                            .font(AppTheme.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(peliculasEnLista) { movie in
                            NavigationLink(destination: DetailView(movie: movie)) {
                                MovieCardView(movie: movie)
                            }
                            .listRowBackground(AppTheme.surface)
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
        }
        .navigationTitle(list.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddSheet = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(AppTheme.accent)
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
            ZStack {
                AppTheme.background.ignoresSafeArea()
                Group {
                    if disponibles.isEmpty {
                        Text("Todas las películas disponibles ya están en esta lista.")
                            .font(AppTheme.body)
                            .foregroundColor(AppTheme.textSecondary)
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
                                        .font(AppTheme.body)
                                        .foregroundColor(AppTheme.textPrimary)
                                    Spacer()
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(AppTheme.accent)
                                }
                                .padding(.vertical, 4)
                            }
                            .listRowBackground(AppTheme.surface)
                        }
                        .listStyle(PlainListStyle())
                    }
                }
            }
            .navigationTitle("Añadir a lista")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") { presentationMode.wrappedValue.dismiss() }
                        .foregroundColor(AppTheme.accent)
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
