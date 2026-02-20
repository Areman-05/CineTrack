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

                RefreshableScrollView(isRefreshing: $isRefreshing, onRefresh: {
                    viewModel.loadExploreMovies()
                }) {
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
                            // Cambiamos el ForEach para que sea más estable
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.exploreMovies) { movie in
                                    // Usamos un ID explícito para asegurar que SwiftUI no se pierda
                                    NavigationLink(destination: DetailView(movie: movie)) {
                                        MovieCardView(movie: movie, viewModel: viewModel, showFavorite: true, showWatchStatus: false, large: true)
                                    }
                                    .buttonStyle(PlainButtonStyle())
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
            // Eliminamos el onChange que causaba el bucle infinito
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
