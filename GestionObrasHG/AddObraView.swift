import SwiftUI

struct AddObraView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var nombre = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Nombre de la obra", text: $nombre)
                Button("Guardar") {
                    let nuevaObra = Obra(context: viewContext)
                    nuevaObra.id = UUID()
                    nuevaObra.nombre = nombre
                    try? viewContext.save()
                    dismiss()
                }
            }
            .navigationTitle("Nueva Obra")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }
}
