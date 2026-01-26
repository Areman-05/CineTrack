//
//  AsyncImageView.swift
//  CineTrack
//
//  Componente de imagen asíncrona compatible con iOS 14.4
//

import SwiftUI
import UIKit

// ActivityIndicator compatible con iOS 14.4
struct ActivityIndicator: UIViewRepresentable {
    var color: Color = .primary
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.startAnimating()
        // Convertir Color a UIColor compatible con iOS 14.4
        indicator.color = colorToUIColor(color)
        return indicator
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        uiView.color = colorToUIColor(color)
    }
    
    // Helper para convertir Color a UIColor en iOS 14.4
    private func colorToUIColor(_ color: Color) -> UIColor {
        // Para iOS 14, usamos una aproximación basada en los colores del sistema
        switch color {
        case .primary:
            return .label
        case .secondary:
            return .secondaryLabel
        case .yellow:
            return .systemYellow
        case .red:
            return .systemRed
        case .blue:
            return .systemBlue
        case .green:
            return .systemGreen
        case .gray:
            return .systemGray
        case .white:
            return .white
        case .black:
            return .black
        default:
            // Para otros colores, intentamos usar el inicializador si está disponible
            if #available(iOS 15.0, *) {
                return UIColor(color)
            } else {
                // Fallback a un color por defecto
                return .label
            }
        }
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
