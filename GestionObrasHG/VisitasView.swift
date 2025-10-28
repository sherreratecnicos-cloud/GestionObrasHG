import SwiftUI

struct VisitasView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var obra: Obra?

    var body: some View {
        List {
            if let visitas = obra?.visitas {
                ForEach(Array(visitas), id: \.id) { visita in
                    NavigationLink(visita.fecha?.description ?? "Sin fecha") {
                        VisitaDetailView(visita: visita)
                    }
                }
            }
        }
        .navigationTitle("Visitas")
    }
}
