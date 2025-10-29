#!/bin/bash
set -e

echo "🏗️  Generando proyecto completo GestionObrasHG (Swift 6, iOS 17)…"

# Limpiar y crear estructura
rm -rf GestionObrasHG
mkdir -p GestionObrasHG/GestionObrasHG/{Models,Views,Assets.xcassets,Resources,PDFs}
mkdir -p GestionObrasHG.xcodeproj

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

# ---------- App principal ----------
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

# ---------- Modelos ----------
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

# ---------- Controlador de datos ----------
cat > GestionObrasHG/Models/DataController.swift <<'EOF'
import Foundation
import SwiftUI

class DataController: ObservableObject {
    @Published var obras: [Obra] = []
    private let saveKey = "obrasGuardadas.json"

    init() {
        load()
    }

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

# ---------- Vista principal ----------
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
                                .foregroundColor(.gray)
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

# ---------- Nueva obra ----------
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
                    Button("Cancelar", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
}
EOF

# ---------- Detalle de obra ----------
cat > GestionObrasHG/Views/DetalleObraView.swift <<'EOF'
import SwiftUI

struct DetalleObraView: View {
    let obra: Obra

    var body: some View {
        VStack {
            if obra.visitas.isEmpty {
                Text("Sin visitas registradas")
                    .foregroundColor(.gray)
                    .padding()
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

# ---------- Proyecto Xcode ----------
cat > GestionObrasHG.xcodeproj/project.pbxproj <<'EOF'
// !$*UTF8*$!
{
    archiveVersion = 1;
    classes = {};
    objectVersion = 56;
    objects = {

        1 = {isa = PBXFileReference; path = GestionObrasHG/App.swift; sourceTree = "<group>"; };
        2 = {isa = PBXFileReference; path = GestionObrasHG/Models/Models.swift; sourceTree = "<group>"; };
        3 = {isa = PBXFileReference; path = GestionObrasHG/Models/DataController.swift; sourceTree = "<group>"; };
        4 = {isa = PBXFileReference; path = GestionObrasHG/Views/ListaObrasView.swift; sourceTree = "<group>"; };
        5 = {isa = PBXFileReference; path = GestionObrasHG/Views/NuevaObraView.swift; sourceTree = "<group>"; };
        6 = {isa = PBXFileReference; path = GestionObrasHG/Views/DetalleObraView.swift; sourceTree = "<group>"; };

        10 = {isa = PBXFileReference; explicitFileType = wrapper.application; path = GestionObrasHG.app; sourceTree = BUILT_PRODUCTS_DIR; };

        20 = {isa = PBXSourcesBuildPhase; files = (1, 2, 3, 4, 5, 6); };

        30 = {
            isa = PBXNativeTarget;
            buildConfigurationList = 31;
            buildPhases = (20);
            name = GestionObrasHG;
            productName = GestionObrasHG;
            productReference = 10;
            productType = "com.apple.product-type.application";
        };

        31 = {
            isa = XCConfigurationList;
            buildConfigurations = (60, 61);
            defaultConfigurationName = Release;
        };

        40 = {
            isa = PBXProject;
            buildConfigurationList = 41;
            mainGroup = 50;
            productRefGroup = 51;
            targets = (30);
            compatibilityVersion = "Xcode 16.0";
        };

        41 = {
            isa = XCConfigurationList;
            buildConfigurations = (60, 61);
            defaultConfigurationName = Release;
        };

        50 = {isa = PBXGroup; children = (1, 2, 3, 4, 5, 6); sourceTree = "<group>"; };
        51 = {isa = PBXGroup; children = (10); name = Products; sourceTree = "<group>"; };

        // Release build configuration
        60 = {
            isa = XCBuildConfiguration;
            name = Release;
            buildSettings = {
                PRODUCT_NAME = "$(TARGET_NAME)";
                SDKROOT = iphoneos;
                IPHONEOS_DEPLOYMENT_TARGET = 17.0;
                SWIFT_VERSION = 6.0;
                SWIFT_OPTIMIZATION_LEVEL = "$(inherited)";
                SWIFT_COMPILATION_MODE = wholemodule;
                SWIFT_ACTIVE_COMPILATION_CONDITIONS = "SWIFTUI_PREVIEWS_DISABLED";
                CODE_SIGNING_ALLOWED = NO;
                CODE_SIGNING_REQUIRED = NO;
            };
        };

        // Debug build configuration
        61 = {
            isa = XCBuildConfiguration;
            name = Debug;
            buildSettings = {
                PRODUCT_NAME = "$(TARGET_NAME)";
                SDKROOT = iphoneos;
                IPHONEOS_DEPLOYMENT_TARGET = 17.0;
                SWIFT_VERSION = 6.0;
                SWIFT_OPTIMIZATION_LEVEL = "-Onone";
                SWIFT_COMPILATION_MODE = incremental;
                CODE_SIGNING_ALLOWED = NO;
                CODE_SIGNING_REQUIRED = NO;
            };
        };
    };
    rootObject = 40;
}
EOF

echo "✅ Proyecto Xcode listo (Swift 6, iOS 17, sin conflicto de Previews)."
