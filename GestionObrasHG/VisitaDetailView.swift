import SwiftUI

struct VisitaDetailView: View {
    @ObservedObject var visita: Visita

    var body: some View {
        List {
            Section("Anotaciones") {
                NavigationLink("Ver Anotaciones") {
                    AnotacionesView(visita: visita)
                }
                NavigationLink("Añadir Anotación") {
                    AddAnotacionView(visita: visita)
                }
            }
        }
        .navigationTitle(visita.fecha?.description ?? "")
    }
}
