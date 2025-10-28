import SwiftUI

struct AddObraView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var nombre = ""
    @State private var ubicacion = ""

    var body: some View {
        Form {
            TextField("Nombre", text: $nombre)
            TextField("Ubicación", text: $ubicacion)
            Button("Guardar") {
                let nuevaObra = Obra(context: viewContext)
                nuevaObra.id = UUID()
                nuevaObra.nombre = nombre
                nuevaObra.ubicacion = ubicacion
                try? viewContext.save()
                dismiss()
            }
        }
        .navigationTitle("Nueva Obra")
    }
}
