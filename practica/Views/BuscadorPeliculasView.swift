import SwiftUI

struct BuscadorPeliculasView: View {
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Buscador de Películas")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Buscar películas...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            
            if searchText.isEmpty {
                Text("Escribe para buscar películas")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                Text("Buscando: \(searchText)")
                    .foregroundColor(.blue)
                    .padding()
            }
            
            Spacer()
        }
        .padding()
    }
}

#if DEBUG
struct BuscadorPeliculasView_Previews: PreviewProvider {
    static var previews: some View {
        BuscadorPeliculasView()
    }
}
#endif
