//
//  FavoritosView.swift
//  CineTrack
//
//  Vista de películas favoritas
//

import SwiftUI

struct FavoritosView: View {
    @EnvironmentObject var viewModel: MovieViewModel
    
    var favoriteMovies: [Movie] {
        viewModel.favoriteMovies
    }
    
    var body: some View {
        NavigationView {
            Group {
                if favoriteMovies.isEmpty {
                    // Empty State
                    VStack(spacing: 16) {
                        Image(systemName: "heart")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No tienes favoritos aún")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Marca películas como favoritas para verlas aquí")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(favoriteMovies) { movie in
                                NavigationLink(destination: DetailView(movie: movie, viewModel: viewModel)) {
                                    MovieCard(movie: movie, isFavorite: true)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Favoritos")
        }
    }
}

#Preview {
    FavoritosView()
        .environmentObject(MovieViewModel())
}
