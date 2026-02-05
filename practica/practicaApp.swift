import SwiftUI

@main
struct practicaApp: App {
    init() {
        // Inicialización de la app - útil para debugging
        print("🚀 practicaApp inicializada")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    print("✅ ContentView apareció")
                }
        }
    }
}
