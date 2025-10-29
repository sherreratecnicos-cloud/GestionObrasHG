#!/bin/bash
set -e

echo "🏗️  Generando proyecto completo GestionObrasHG (Swift 6, iOS 17)…"

# ---------- Limpiar ----------
rm -rf GestionObrasHG GestionObrasHG.xcodeproj build
mkdir -p GestionObrasHG/GestionObrasHG/{Models,Views,Assets.xcassets,Resources,PDFs}
mkdir -p build

cd GestionObrasHG

# ---------- Package.swift ----------
cat > Package.swift <<'EOF'
// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "GestionObrasHG",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "GestionObrasHG", targets: ["GestionObrasHG"])
    ],
    targets: [
        .target(
            name: "GestionObrasHG",
            path: "GestionObrasHG"
        )
    ]
)
EOF

# ---------- App.swift ----------
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

# ---------- Models ----------
cat > GestionObrasHG/Models/Models.swift <<'EOF'
import Foundation
import SwiftUI

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

cat > GestionObrasHG/Models/DataController.swift <<'EOF'
import Foundation
import SwiftUI

class DataController: ObservableObject {
    @Published var obras: [Obra] = []
    private let saveKey = "obrasGuardadas.json"

    init() { load() }

    func load() {
        let url = getDocumentsDirectory().appendingPathComponent(saveKey)
        if let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([Obra].self, from: data) {
            obras = decoded
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

# ---------- Views ----------
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
                            Text(obra.nombre).font(.headline)
                            Text(obra.direccion).font(.subheadline).foregroundColor(.gray)
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
            .sheet(isPresented: $showingAddObra) { NuevaObraView() }
        }
    }
}
EOF

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
            .navigationTitle("Nueva Obra")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        data.addObra(nombre: nombre, direccion: direccion)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar", role: .cancel) { dismiss() }
                }
            }
        }
    }
}
EOF

cat > GestionObrasHG/Views/DetalleObraView.swift <<'EOF'
import SwiftUI

struct DetalleObraView: View {
    let obra: Obra

    var body: some View {
        VStack {
            if obra.visitas.isEmpty {
                Text("Sin visitas registradas").foregroundColor(.gray).padding()
            } else {
                List(obra.visitas) { visita in
                    Text(visita.descripcion)
                }
            }
        }
        .navigationTitle(obra.nombre)
    }
}
EOF

cd ..

# ---------- Crear esquema compartido ----------
mkdir -p GestionObrasHG.xcodeproj/xcshareddata/xcschemes

cat > GestionObrasHG.xcodeproj/xcshareddata/xcschemes/GestionObrasHG.xcscheme <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1410"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildFor = "running"
            buildableReference = {
               BlueprintIdentifier = "30";
               BuildableName = "GestionObrasHG.app";
               BlueprintName = "GestionObrasHG";
               ReferencedContainer = "container:GestionObrasHG.xcodeproj";
            }/>
      </BuildActionEntries>
   </BuildAction>
   <LaunchAction
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "30"
            BuildableName = "GestionObrasHG.app"
            BlueprintName = "GestionObrasHG"
            ReferencedContainer = "container:GestionObrasHG.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
</Scheme>
EOF

# ---------- Archive para cualquier dispositivo iOS ----------
echo "🏗️  Archivando proyecto para Any iOS Device…"

xcodebuild archive \
  -project GestionObrasHG.xcodeproj \
  -scheme GestionObrasHG \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath ./build/GestionObrasHG.xcarchive \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  SWIFT_VERSION=6.0 \
  SWIFT_COMPILATION_MODE=wholemodule \
  SWIFT_OPTIMIZATION_LEVEL=-Owholemodule \
  SWIFT_ACTIVE_COMPILATION_CONDITIONS=SWIFTUI_PREVIEWS_DISABLED

echo "✅ Proyecto GestionObrasHG archivado correctamente en ./build/GestionObrasHG.xcarchive"
