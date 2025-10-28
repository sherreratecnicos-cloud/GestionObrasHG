import SwiftUI
import CoreData

struct ObrasView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Obra.nombre, ascending: true)],
        animation: .default)
    private var obras: FetchedResults<Obra>
    
    @State private var showAddObra = false

    var body: some View {
        NavigationView {
            List {
                ForEach(obras) { obra in
                    NavigationLink(obra.nombre ?? "Sin nombre") {
                        ObraDetailView(obra: obra)
                    }
                }
                .onDelete(perform: deleteObras)
            }
            .navigationTitle("Obras")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddObra = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddObra) {
                AddObraView()
            }
        }
    }
    
    private func deleteObras(offsets: IndexSet) {
        for index in offsets {
            let obra = obras[index]
            viewContext.delete(obra)
        }
        try? viewContext.save()
    }
}
