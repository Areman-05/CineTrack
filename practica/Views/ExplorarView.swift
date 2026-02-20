import SwiftUI

struct ExplorarView: View {
    @EnvironmentObject var viewModel: MovieViewModel

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoadingExplore {
                    ProgressView("Cargando...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.exploreErrorMessage {
                    VStack(spacing: 16) {
                        Text(error)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Reintentar") {
                            viewModel.loadExploreMovies()
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                } else if viewModel.exploreMovies.isEmpty {
                    Text("Pulsa Actualizar para cargar películas.")
                        .foregroundColor(.secondary)
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
            .navigationTitle("Explorar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.loadExploreMovies() }) {
                        Image(systemName: "arrow.clockwise")
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
