import SwiftUI

struct ObraDetailView: View {
    @ObservedObject var obra: Obra

    var body: some View {
        List {
            Section("Visitas") {
                NavigationLink("Ver Visitas") {
                    VisitasView(obra: obra)
                }
                NavigationLink("Añadir Visita") {
                    AddVisitaView(obra: obra)
                }
            }
        }
        .navigationTitle(obra.nombre ?? "")
    }
}
