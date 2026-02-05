import SwiftUI

struct ContentView: View {
    init() {
        print("📱 ContentView inicializada")
    }
    
    var body: some View {
        BuscadorPeliculasView()
            .onAppear {
                print("✅ BuscadorPeliculasView apareció")
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
