#!/bin/bash
set -e

echo "🏗️  Generando estructura del proyecto GestionObrasHG..."

# Crear carpeta raíz del proyecto
rm -rf GestionObrasHG
mkdir -p GestionObrasHG
cd GestionObrasHG

# Crear estructura de carpetas
mkdir -p GestionObrasHG/Models
mkdir -p GestionObrasHG/Views
mkdir -p GestionObrasHG/Assets.xcassets
mkdir -p GestionObrasHG/Resources
mkdir -p GestionObrasHG/PDFs

# Crear archivo de configuración del proyecto SwiftUI
cat > GestionObrasHG.xcodeproj/project.pbxproj <<'EOF'
// Proyecto base generado automáticamente
// Puedes abrirlo directamente con Xcode
EOF

# Crear archivo principal de la app
cat > GestionObrasHG/App.swift <<'EOF'
import SwiftUI

@main
struct GestionObrasHGApp: App {
    @StateObject private var dataController = DataController()

    var body: some Scene {
        WindowGroup {
            ListaObrasView()
                .environmentObject(dataController)
        }
    }
}
EOF

# Crear modelo de datos principal
cat > GestionObrasHG/Models/Models.swift <<'EOF'
import Foundation
import SwiftUI
import UIKit

struct Obra: Identifiable, Codable {
    var id = UUID()
    var nombre: String
    var direccion: String
    var visitas: [Visita] = []
}

struct Visita: Identifiable, Codable {
    var id = UUID()
    var fecha: Date
    var descripcion: String
    var imagenGeneral: Data?
    var anotaciones: [Anotacion] = []
}

struct Anotacion: Identifiable, Codable {
    var id = UUID()
    var texto: String
    var foto: Data?
}
EOF

# Controlador de datos con persistencia local
cat > GestionObrasHG/Models/DataController.swift <<'EOF'
import Foundation
import SwiftUI
import UIKit

class DataController: ObservableObject {
    @Published var obras: [Obra] = []

    private let saveKey = "obrasGuardadas.json"

    init() {
        load()
    }

    func load() {
        let url = getDocumentsDirectory().appendingPathComponent(saveKey)
        if let data = try? Data(contentsOf: url) {
            if let decoded = try? JSONDecoder().decode([Obra].self, from: data) {
                obras = decoded
            }
        }
    }

    func save() {
        let url = getDocumentsDirectory().appendingPathComponent(saveKey)
        if let data = try? JSONEncoder().encode(obras) {
            try? data.write(to: url)
        }
    }

    func addObra(nombre: String, direccion: String) {
        obras.append(Obra(nombre: nombre, direccion: direccion))
        save()
    }

    func deleteObra(at offsets: IndexSet) {
        obras.remove(atOffsets: offsets)
        save()
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
EOF

# Vista principal de listado de obras
cat > GestionObrasHG/Views/ListaObrasView.swift <<'EOF'
import SwiftUI

struct ListaObrasView: View {
    @EnvironmentObject var data: DataController
    @State private var showingAddObra = false

    var body: some View {
        NavigationView {
            List {
                ForEach(data.obras) { obra in
                    NavigationLink(destination: DetalleObraView(obra: obra)) {
                        VStack(alignment: .leading) {
                            Text(obra.nombre)
                                .font(.headline)
                            Text(obra.direccion)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: data.deleteObra)
            }
            .navigationTitle("Obras")
            .toolbar {
                Button(action: { showingAddObra = true }) {
                    Label("Nueva Obra", systemImage: "plus.circle.fill")
                }
            }
            .sheet(isPresented: $showingAddObra) {
                NuevaObraView()
            }
        }
    }
}
EOF

# Vista para añadir una nueva obra
cat > GestionObrasHG/Views/NuevaObraView.swift <<'EOF'
import SwiftUI

struct NuevaObraView: View {
    @EnvironmentObject var data: DataController
    @Environment(\.dismiss) var dismiss

    @State private var nombre = ""
    @State private var direccion = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Nombre de la obra", text: $nombre)
                TextField("Dirección", text: $direccion)
            }
            .navigationTitle("Nueva obra")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        data.addObra(nombre: nombre, direccion: direccion)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
}
EOF

# Vista de detalle de obra (visitas)
cat > GestionObrasHG/Views/DetalleObraView.swift <<'EOF'
import SwiftUI

struct DetalleObraView: View {
    let obra: Obra

    var body: some View {
        List {
            ForEach(obra.visitas) { visita in
                Text(visita.descripcion)
            }
        }
        .navigationTitle(obra.nombre)
    }
}
EOF

echo "✅ Proyecto GestionObrasHG generado correctamente."
