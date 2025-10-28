import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ObrasView()
                .tabItem { Label("Obras", systemImage: "building.2") }

            VisitasView()
                .tabItem { Label("Visitas", systemImage: "calendar") }

            AnotacionesView()
                .tabItem { Label("Anotaciones", systemImage: "note.text") }
        }
    }
}
