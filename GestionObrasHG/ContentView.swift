import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Obras") { ObrasView() }
                NavigationLink("Visitas") { VisitasView() }
                NavigationLink("Anotaciones") { AnotacionesView() }
            }
            .navigationTitle("Gestión Obras HG")
        }
    }
}
