import SwiftUI

/// Vista Explorar: películas mejor valoradas (diferente a Inicio). Con refresh.
/// Compatible con iOS 14.4.
struct ExplorarView: View {
    @EnvironmentObject private var viewModel: MovieViewModel
    @State private var isRefreshing = false

    var body: some View {
        // Mantenemos el NavigationView solo si esta vista NO está dentro de otro NavigationView previo
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Mejor valoradas")
                            .font(AppTheme.titleMedium)
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)

                        if viewModel.isLoadingExplore && !isRefreshing {
                            loadingView
                        } else if let error = viewModel.exploreErrorMessage {
                            errorView(error)
                        } else {
                            VStack(spacing: 16) {
                                ForEach(viewModel.exploreMovies) { movie in
                                    NavigationLink(destination: DetailView(movie: movie)) {
                                        MovieCardView(movie: movie, viewModel: viewModel, showFavorite: true, showWatchStatus: false, large: true)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .contextMenu {
                                        Button(action: { viewModel.toggleFavorite(movieId: movie.id, movie: movie) }) {
                                            Label(viewModel.isFavorite(movieId: movie.id) ? "Quitar de Favoritos" : "Añadir a Favoritos", systemImage: viewModel.isFavorite(movieId: movie.id) ? "heart.slash" : "heart")
                                        }
                                        if !viewModel.favoriteLists.isEmpty {
                                            ForEach(viewModel.favoriteLists) { list in
                                                Button(action: { viewModel.addMovieToList(movieId: movie.id, listId: list.id, movie: movie) }) {
                                                    Label(list.name, systemImage: "folder")
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Explorar")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isRefreshing = true
                        viewModel.loadExploreMovies()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(AppTheme.accent)
                    }
                }
            }
            .onAppear {
                if viewModel.exploreMovies.isEmpty {
                    viewModel.loadExploreMovies()
                }
            }
            .onChange(of: viewModel.isLoadingExplore, perform: { loading in
                if !loading { isRefreshing = false }
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // Componentes extraídos para limpiar el body
    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.accent))
                .scaleEffect(1.2)
            Text("Cargando...")
                .font(AppTheme.subheadline)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    private func errorView(_ error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 44))
                .foregroundColor(AppTheme.error)
            Text(error)
                .font(AppTheme.body)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Reintentar") { viewModel.loadExploreMovies() }
                .font(AppTheme.headline)
                .foregroundColor(AppTheme.accent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}

#if DEBUG
struct ExplorarView_Previews: PreviewProvider {
    static var previews: some View {
        ExplorarView()
            .environmentObject(MovieViewModel())
    }
}
#endif
