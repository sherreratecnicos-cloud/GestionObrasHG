import SwiftUI

struct ObraDetailView: View {
    @ObservedObject var obra: Obra
    @State private var showAddVisita = false

    var body: some View {
        VStack {
            Text(obra.nombre ?? "Sin nombre")
                .font(.largeTitle)
                .padding()
            
            List {
                ForEach(obra.visitasArray) { visita in
                    NavigationLink(visita.fecha ?? Date(), destination: VisitaDetailView(visita: visita)) {
                        Text(visita.fecha!, style: .date)
                    }
                }
            }
            
            Button("Añadir Visita") { showAddVisita = true }
                .padding()
        }
        .sheet(isPresented: $showAddVisita) {
            AddVisitaView(obra: obra)
        }
    }
}
