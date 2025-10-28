import SwiftUI

struct AddVisitaView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var obra: Obra
    @State private var fecha = Date()
    @State private var observaciones = ""

    var body: some View {
        NavigationView {
            Form {
                DatePicker("Fecha de la visita", selection: $fecha, displayedComponents: .date)
                TextField("Observaciones", text: $observaciones)
                
                Button("Guardar") {
                    let nuevaVisita = Visita(context: viewContext)
                    nuevaVisita.id = UUID()
                    nuevaVisita.fecha = fecha
                    nuevaVisita.observaciones = observaciones
                    nuevaVisita.obra = obra
                    
                    try? viewContext.save()
                    dismiss()
                }
            }
            .navigationTitle("Nueva Visita")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }
}
