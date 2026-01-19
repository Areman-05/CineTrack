import SwiftUI

/// Vista de detalle de una película
/// Muestra información completa, opciones de guardado y plataformas de streaming
struct DetailView: View {
    @EnvironmentObject private var viewModel: MovieViewModel
    @Environment(\.presentationMode) var presentationMode
    let movie: Movie
    
    @State private var selectedStatus = "To Watch"
    @State private var personalNote = ""
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header Image
                    headerImage
                    
                    // Movie Info
                    movieInfo
                    
                    // Personal Records
                    personalRecords
                    
                    // Action Buttons
                    actionButtons
                    
                    // Synopsis
                    synopsis
                    
                    // Where to Watch
                    whereToWatch
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private var headerImage: some View {
        ZStack(alignment: .topLeading) {
            URLImage(url: movie.posterURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(height: 500)
            .clipped()
            
            // Gradient Overlay
            LinearGradient(
                gradient: Gradient(colors: [Color.clear, Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Back Button
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: {
                        viewModel.toggleFavorite(movieId: movie.id)
                    }) {
                        Image(systemName: viewModel.isFavorite(movieId: movie.id) ? "heart.fill" : "heart")
                            .foregroundColor(viewModel.isFavorite(movieId: movie.id) ? .red : .white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
            }
            .padding()
        }
    }
    
    private var movieInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("TV SERIES")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(4)
                
                Text("SCI-FI")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
            
            Text(movie.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("3 Seasons • 24 Episodes")
                .font(.subheadline)
                .foregroundColor(.yellow)
            
            // Stats
            HStack(spacing: 24) {
                VStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("RATING")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text(String(format: "%.1f/5", movie.voteAverage / 2))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.yellow)
                    Text("YEAR")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text(movie.releaseYear)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack {
                    Image(systemName: "clock")
                        .foregroundColor(.yellow)
                    Text("RUNTIME")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text("45m/ep")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack {
                    Image(systemName: "tv")
                        .foregroundColor(.yellow)
                    Text("AUDIO")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text("EN/ES")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
        }
        .padding()
    }
    
    private var personalRecords: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("PERSONAL RECORDS")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "pencil")
                        .foregroundColor(.gray)
                }
            }
            
            // Status Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("STATUS")
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Menu {
                    Button("To Watch") { selectedStatus = "To Watch" }
                    Button("Watching") { selectedStatus = "Watching" }
                    Button("Completed") { selectedStatus = "Completed" }
                } label: {
                    HStack {
                        Text(selectedStatus)
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.yellow)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
            }
            
            // Personal Note
            VStack(alignment: .leading, spacing: 8) {
                Text("PERSONAL NOTE")
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                TextField("Add your thoughts about this show...", text: $personalNote)
                    .foregroundColor(.gray)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {}) {
                HStack {
                    Image(systemName: "trash")
                    Text("REMOVE FROM MY LIST")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.red, lineWidth: 1)
                )
            }
            
            Button(action: {}) {
                HStack {
                    Image(systemName: "checkmark")
                    Text("SAVE CHANGES")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.yellow)
                .cornerRadius(8)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var synopsis: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(movie.overview)
                .font(.body)
                .foregroundColor(.gray)
                .lineLimit(nil)
        }
        .padding()
    }
    
    private var whereToWatch: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Where to Watch")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                streamingPlatform(name: "Netflix", color: .red)
                streamingPlatform(name: "Disney+", color: .blue)
            }
        }
        .padding()
    }
    
    private func streamingPlatform(name: String, color: Color) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(name.prefix(1)))
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                )
            
            VStack(alignment: .leading) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text("SUBSCRIPTION")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
}

}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(movie: Movie(
            id: 1,
            title: "Neon Echoes: The Final Synthesis",
            overview: "In a world where consciousness can be digitized...",
            posterPath: nil,
            voteAverage: 8.5,
            releaseDate: "2023-01-01"
        ))
        .environmentObject(MovieViewModel())
    }
}
