import SwiftUI

struct VisitaDetailView: View {
    var visita: Visita

    var body: some View {
        VStack(spacing: 16) {
            Text("Detalle de visita")
                .font(.title2)
                .bold()

            Text(visita.descripcion)
                .font(.body)
                .padding()

            // 🔧 Temporal: sustituir cuando implementes AnotacionesView
            Text("Sección de anotaciones pendiente de implementar")
        }
        .navigationTitle("Visita")
    }
}
