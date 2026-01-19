import SwiftUI

// MARK: - Buscar View
struct BuscarView: View {
    @EnvironmentObject var viewModel: MovieViewModel
    @State private var searchText = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Buscar películas o géneros...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .onSubmit {
                                performSearch()
                            }
                            .onChange(of: searchText) { newValue in
                                if !newValue.isEmpty {
                                    performSearch()
                                } else {
                                    viewModel.movies = []
                                }
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                viewModel.movies = []
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Buscando...")
                    Spacer()
                } else if searchText.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("Escribe para buscar películas")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else if viewModel.movies.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "film.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No se encontraron resultados")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Intenta con otros términos de búsqueda")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.movies) { movie in
                                NavigationLink(destination: DetailView(movie: movie, viewModel: viewModel)) {
                                    MovieCard(movie: movie, isFavorite: viewModel.isFavorite(movieId: movie.id))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Buscar")
            .alert("Error", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .onChange(of: viewModel.errorMessage) { newValue in
                if newValue != nil {
                    showingAlert = true
                }
            }
        }
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        viewModel.searchMovies(query: searchText)
    }
}

#Preview {
    BuscarView()
        .environmentObject(MovieViewModel())
}
