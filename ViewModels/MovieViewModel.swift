//
//  MovieViewModel.swift
//  CineTrack
//
//  ViewModel para gestionar el estado de las películas
//

import Foundation
import SwiftUI

@MainActor
class MovieViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userPreferences: [Int: UserPreference] = [:]
    
    private let tmdbService = TMDBService.shared
    
    // Cargar películas populares
    func loadPopularMovies() {
        isLoading = true
        errorMessage = nil
        
        tmdbService.fetchPopularMovies { [weak self] result in
            Task { @MainActor in
                self?.isLoading = false
                switch result {
                case .success(let movies):
                    self?.movies = movies
                case .failure(let error):
                    self?.errorMessage = "Error al cargar películas: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // Buscar películas
    func searchMovies(query: String) {
        guard !query.isEmpty else {
            loadPopularMovies()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        tmdbService.searchMovies(query: query) { [weak self] result in
            Task { @MainActor in
                self?.isLoading = false
                switch result {
                case .success(let movies):
                    self?.movies = movies
                case .failure(let error):
                    self?.errorMessage = "Error en la búsqueda: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // Toggle favorito
    func toggleFavorite(movieId: Int) {
        if userPreferences[movieId] == nil {
            userPreferences[movieId] = UserPreference(isFavorite: true)
        } else {
            userPreferences[movieId]?.isFavorite.toggle()
        }
    }
    
    // Verificar si es favorito
    func isFavorite(movieId: Int) -> Bool {
        return userPreferences[movieId]?.isFavorite ?? false
    }
    
    // Obtener películas favoritas
    var favoriteMovies: [Movie] {
        movies.filter { isFavorite(movieId: $0.id) }
    }
}
