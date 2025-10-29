import SwiftUI

struct VisitasView: View {
    @ObservedObject var obra: Obra

    var body: some View {
        List {
            ForEach(Array(obra.visitas ?? []), id: \.id) { visita in
                Text(visita.descripcion)
            }
        }
        .navigationTitle("Visitas")
    }
}

#Preview {
    // Si tienes un ejemplo de Obra, úsalo; si no, comenta esta línea
    // VisitasView(obra: Obra.example)
    Text("Vista previa de VisitasView")
}
