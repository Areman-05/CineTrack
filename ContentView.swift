//
//  ContentView.swift
//  CineTrack
//
//  Created on iOS 15
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "film.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Bienvenido a CineTrack")
                .font(.title)
                .padding()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
