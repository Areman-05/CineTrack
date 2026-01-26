import SwiftUI

struct BuscadorPeliculasView: View {
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Buscador de Películas")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Buscar películas...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 8)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
            
            if searchText.isEmpty {
                Text("Escribe para buscar películas")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            } else {
                Text("Buscando: \(searchText)")
                    .foregroundColor(.blue)
                    .font(.headline)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct BuscadorPeliculasView_Previews: PreviewProvider {
    static var previews: some View {
        BuscadorPeliculasView()
    }
}
