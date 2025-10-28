import SwiftUI

struct AddAnotacionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var visita: Visita

    @State private var texto = ""
    @State private var fecha = Date()

    var body: some View {
        Form {
            TextField("Texto", text: $texto)
            DatePicker("Fecha", selection: $fecha, displayedComponents: .date)
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
    }
}
