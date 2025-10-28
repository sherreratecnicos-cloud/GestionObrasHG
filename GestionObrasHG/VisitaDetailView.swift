import SwiftUI

struct VisitaDetailView: View {
    @ObservedObject var visita: Visita
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showAddAnotacion = false

    var body: some View {
        VStack {
            Text(visita.fecha ?? Date(), style: .date)
                .font(.title)
                .padding()
            
            List {
                ForEach(visita.anotacionesArray) { anotacion in
                    Text(anotacion.texto ?? "")
                        .padding(.vertical, 5)
                }
                .onDelete(perform: deleteAnotaciones)
            }
            
            Button("Añadir Anotación") { showAddAnotacion = true }
                .padding()
        }
        .sheet(isPresented: $showAddAnotacion) {
            AddAnotacionView(visita: visita)
        }
    }

    private func deleteAnotaciones(offsets: IndexSet) {
        for index in offsets {
            let anotacion = visita.anotacionesArray[index]
            viewContext.delete(anotacion)
        }
        try? viewContext.save()
    }
}
