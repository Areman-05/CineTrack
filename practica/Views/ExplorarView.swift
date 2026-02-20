import SwiftUI

/// Vista Explorar: películas populares. Todo el contenido es scrollable.
/// Compatible con iOS 14.4.
struct ExplorarView: View {
    @EnvironmentObject private var viewModel: MovieViewModel

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Películas populares")
                            .font(AppTheme.titleMedium)
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)

                        if viewModel.isLoadingPopular {
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
                        } else if let error = viewModel.popularErrorMessage {
                            VStack(spacing: 12) {
                                Image(systemName: "wifi.exclamationmark")
                                    .font(.system(size: 44))
                                    .foregroundColor(AppTheme.error)
                                Text(error)
                                    .font(AppTheme.body)
                                    .foregroundColor(AppTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 48)
                        } else if viewModel.popularMovies.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "film.stack")
                                    .font(.system(size: 44))
                                    .foregroundColor(AppTheme.textTertiary)
                                Text("No hay películas populares")
                                    .font(AppTheme.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 48)
                        } else {
                            ForEach(viewModel.popularMovies) { movie in
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
            .onAppear {
                if viewModel.popularMovies.isEmpty && !viewModel.isLoadingPopular {
                    viewModel.loadPopularMovies()
                }
            }
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
