import SwiftUI

struct BuscadorPeliculasView: View {
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            Text("Buscador de Películas")
                .font(.title)
                .padding()
            
            TextField("Buscar...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Text(searchText.isEmpty ? "Escribe algo" : "Buscando: \(searchText)")
                .padding()
            
            Spacer()
        }
    }
}

struct BuscadorPeliculasView_Previews: PreviewProvider {
    static var previews: some View {
        BuscadorPeliculasView()
    }
}
