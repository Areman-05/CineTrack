import SwiftUI

struct ExplorarView: View {
    @EnvironmentObject var viewModel: MovieViewModel

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                Group {
                    if viewModel.isLoadingExplore {
                        ProgressView("Cargando...")
                            .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.accent))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = viewModel.exploreErrorMessage {
                        VStack(spacing: 16) {
                            Text(error)
                                .font(AppTheme.body)
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding()
                            Button("Reintentar") {
                                viewModel.loadExploreMovies()
                            }
                            .font(AppTheme.headline)
                            .foregroundColor(Color(red: 0.12, green: 0.10, blue: 0.04))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(AppTheme.accent)
                            .cornerRadius(AppTheme.posterCornerRadius)
                        }
                    } else if viewModel.exploreMovies.isEmpty {
                        Text("Pulsa Actualizar para cargar películas.")
                            .font(AppTheme.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(viewModel.exploreMovies) { movie in
                                    NavigationLink(destination: DetailView(movie: movie)) {
                                        MovieCardView(movie: movie)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                }
            }
            .navigationTitle("Explorar")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.loadExploreMovies() }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(AppTheme.accent)
                    }
                    .disabled(viewModel.isLoadingExplore)
                }
            }
            .onAppear {
                if viewModel.exploreMovies.isEmpty {
                    viewModel.loadExploreMovies()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ExplorarView_Previews: PreviewProvider {
    static var previews: some View {
        ExplorarView()
            .environmentObject(MovieViewModel())
    }
}
