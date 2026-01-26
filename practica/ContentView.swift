//
//  ContentView.swift
//  practica
//
//  Created by alumne on 1/26/26.
//

/// Vista principal que contiene la navegación por tabs
/// Implementa el patrón MVVM con @StateObject y @EnvironmentObject

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MovieViewModel()
    
    var body: some View {
        TabView {
            ExplorarView()
                .tabItem {
                    Label("Explorar", systemImage: "house.fill")
                }
                .environmentObject(viewModel)
            
            BuscarView()
                .tabItem {
                    Label("Buscar", systemImage: "magnifyingglass")
                }
                .environmentObject(viewModel)
            
            FavoritosView()
                .tabItem {
                    Label("Favoritos", systemImage: "heart.fill")
                }
                .environmentObject(viewModel)
        }
        .accentColor(.yellow)
    }
}
#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif


