import SwiftUI

/// Vista Explorar: películas mejor valoradas (diferente a Inicio). Con refresh.
/// Compatible con iOS 14.4.
struct ExplorarView: View {
    @EnvironmentObject private var viewModel: MovieViewModel
    @State private var isRefreshing = false

    var body: some View {
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

                        if viewModel.isLoadingExplore {
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
                        } else if let error = viewModel.exploreErrorMessage {
                            VStack(spacing: 16) {
                                Image(systemName: "wifi.exclamationmark")
                                    .font(.system(size: 44))
                                    .foregroundColor(AppTheme.error)
                                Text(error)
                                    .font(AppTheme.body)
                                    .foregroundColor(AppTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                                Button(action: { viewModel.loadExploreMovies() }) {
                                    Text("Reintentar")
                                        .font(AppTheme.headline)
                                        .foregroundColor(AppTheme.accent)
                                }
                                .padding(.top, 8)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 48)
                        } else if viewModel.exploreMovies.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "star.circle")
                                    .font(.system(size: 44))
                                    .foregroundColor(AppTheme.textTertiary)
                                Text("Pulsa Actualizar para cargar películas")
                                    .font(AppTheme.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 48)
                        } else {
                            ForEach(viewModel.exploreMovies) { movie in
                                NavigationLink(destination: DetailView(movie: movie)) {
                                    MovieCardView(movie: movie, viewModel: viewModel, showFavorite: true, showWatchStatus: false, large: true)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Explorar")
            .navigationBarTitleDisplayMode(.large)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isRefreshing = true
                        viewModel.loadExploreMovies()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(AppTheme.accent)
                    }
                    .disabled(viewModel.isLoadingExplore)
                }
            })
            .onAppear {
                if viewModel.exploreMovies.isEmpty && !viewModel.isLoadingExplore {
                    viewModel.loadExploreMovies()
                }
            }
            .onChange(of: viewModel.isLoadingExplore, perform: { loading in
                if !loading { isRefreshing = false }
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
