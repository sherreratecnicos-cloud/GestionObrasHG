import SwiftUI

struct AddAnotacionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var visita: Visita
    @State private var texto = ""
    @State private var fecha = Date()

    var body: some View {
        NavigationView {
            Form {
                DatePicker("Fecha", selection: $fecha, displayedComponents: .date)
                TextField("Texto de la anotación", text: $texto)
                
                Button("Guardar") {
                    let nuevaAnotacion = Anotacion(context: viewContext)
                    nuevaAnotacion.id = UUID()
                    nuevaAnotacion.texto = texto
                    nuevaAnotacion.fecha = fecha
                    nuevaAnotacion.visita = visita
                    
                    try? viewContext.save()
                    dismiss()
                }
            }
            .navigationTitle("Nueva Anotación")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }
}
