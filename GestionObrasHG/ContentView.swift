import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                NavigationLink("Obras") {
                    ObrasView()
                }

                // Si tienes la vista AnotacionesView creada, descomenta la siguiente línea:
                // NavigationLink("Anotaciones") { AnotacionesView() }

                Text("Gestión de obras HG")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Gestión de Obras")
        }
    }
}

#Preview {
    ContentView()
}
