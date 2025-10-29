#!/bin/bash
set -e

echo "🏗️ Generando proyecto completo GestionObrasHG (Swift 6, iOS 17)…"

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
   <BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES">
      <BuildActionEntries>
         <BuildActionEntry buildFor="running" buildableReference="{BlueprintIdentifier=30; BuildableName=GestionObrasHG.app; BlueprintName=GestionObrasHG; ReferencedContainer=container:GestionObrasHG.xcodeproj;}"/>
      </BuildActionEntries>
   </BuildAction>
   <LaunchAction selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" allowLocationSimulation="YES">
      <BuildableProductRunnable runnableDebuggingMode="0">
         <BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="30" BuildableName="GestionObrasHG.app" BlueprintName="GestionObrasHG" ReferencedContainer="container:GestionObrasHG.xcodeproj"/>
      </BuildableProductRunnable>
   </LaunchAction>
</Scheme>
EOF

# ---------- Variables para build y export ----------

echo "🏗️  Limpiando, compilando y archivando GestionObrasHG…"

# Variables del proyecto
PROJECT="GestionObrasHG.xcodeproj"
SCHEME="GestionObrasHG"
CONFIGURATION="Release"
ARCHIVE_PATH="./build/GestionObrasHG.xcarchive"
EXPORT_PATH="./build/GestionObrasHG-IPA"
EXPORT_OPTIONS_PLIST="./build/exportOptions.plist"

# Crear carpetas necesarias
mkdir -p build
mkdir -p "$EXPORT_PATH"

# ---------- Export Options plist para .ipa sin firmar ----------
cat > "$EXPORT_OPTIONS_PLIST" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>compileBitcode</key><false/>
    <key>destination</key><string>export</string>
    <key>method</key><string>development</string>
    <key>signingStyle</key><string>none</string>
    <key>stripSwiftSymbols</key><true/>
    <key>thinning</key><string>&lt;none&gt;</string>
</dict>
</plist>
EOF

# ---------- Clean ----------
echo "🧹 Limpiando proyecto…"
xcodebuild clean \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination "generic/platform=iOS" \
  CODE_SIGNING_ALLOWED=NO

# ---------- Build ----------
echo "🔨 Compilando proyecto…"
xcodebuild build \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination "generic/platform=iOS" \
  CODE_SIGNING_ALLOWED=NO \
  SWIFT_VERSION=6.0 \
  SWIFT_COMPILATION_MODE=wholemodule \
  SWIFT_OPTIMIZATION_LEVEL=-Owholemodule \
  SWIFT_ACTIVE_COMPILATION_CONDITIONS=SWIFTUI_PREVIEWS_DISABLED

# ---------- Archive ----------
echo "📦 Archivando proyecto…"
xcodebuild archive \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  SWIFT_VERSION=6.0 \
  SWIFT_COMPILATION_MODE=wholemodule \
  SWIFT_OPTIMIZATION_LEVEL=-Owholemodule \
  SWIFT_ACTIVE_COMPILATION_CONDITIONS=SWIFTUI_PREVIEWS_DISABLED

# ---------- Export IPA ----------
echo "📱 Exportando .ipa sin firmar…"
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS_PLIST"

echo "✅ Proyecto GestionObrasHG archivado en $ARCHIVE_PATH"
echo "✅ .ipa generado en $EXPORT_PATH/GestionObrasHG.ipa (sin firmar)"
