import SwiftUI

struct AsyncImageView: View {
    let url: URL?
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                    )
            }
        }
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        guard let url = url else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let loaded = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = loaded
                }
            }
        }.resume()
    }
}
