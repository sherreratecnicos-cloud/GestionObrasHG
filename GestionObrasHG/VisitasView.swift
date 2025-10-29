import SwiftUI

struct VisitasView: View {
    @ObservedObject var obra: Obra

    var body: some View {
        List {
            ForEach(obra.visitas, id: \.id) { visita in
                Text(visita.descripcion)
            }
        }
        .navigationTitle("Visitas")
    }
}

#Preview {
    // Vista de ejemplo sin datos reales
    VisitasView(obra: Obra.example)
}
