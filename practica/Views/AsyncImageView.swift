//
//  AsyncImageView.swift
//  CineTrack
//
//  Componente de imagen asíncrona compatible con iOS 14.4
//

import SwiftUI

// ActivityIndicator compatible con iOS 14.4
struct ActivityIndicator: UIViewRepresentable {
    var color: Color = .primary
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.startAnimating()
        // Convertir Color a UIColor (disponible desde iOS 14.0)
        indicator.color = UIColor(color)
        return indicator
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        uiView.color = UIColor(color)
    }
}

struct AsyncImageView: View {
    let url: URL?
    @State private var image: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
            } else if isLoading {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ActivityIndicator()
                    )
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        guard let url = url else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let data = data, let loadedImage = UIImage(data: data) {
                    self.image = loadedImage
                }
            }
        }.resume()
    }
}
