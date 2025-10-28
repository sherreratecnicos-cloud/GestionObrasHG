import SwiftUI
import CoreData

struct ObrasView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Obra.nombre, ascending: true)])
    private var obras: FetchedResults<Obra>

    var body: some View {
        List {
            ForEach(obras, id: \.id) { obra in
                NavigationLink(obra.nombre ?? "Sin nombre") {
                    ObraDetailView(obra: obra)
                }
            }
        }
        .navigationTitle("Obras")
        .toolbar {
            NavigationLink("Añadir Obra") {
                AddObraView()
            }
        }
    }
}
