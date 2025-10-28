#!/bin/bash
set -e

echo "🏗️  Generando estructura del proyecto GestionObrasHG..."

# Crear carpeta principal
mkdir -p GestionObrasHG/{Models,Views,Utils,Resources,Assets.xcassets}

cd GestionObrasHG

# Crear archivo principal SwiftUI
cat > GestionObrasHGApp.swift << 'EOF'
import SwiftUI

@main
struct GestionObrasHGApp: App {
    @StateObject private var datos = DatosObras()

    var body: some Scene {
        WindowGroup {
            ListaObrasView()
                .environmentObject(datos)
        }
    }
}
EOF

# Ejemplo: modelo de datos
cat > Models/Obra.swift << 'EOF'
import Foundation

struct Obra: Identifiable, Codable {
    var id = UUID()
    var nombre: String
    var direccion: String
    var visitas: [Visita] = []
}
EOF

cat > Models/Visita.swift << 'EOF'
import Foundation

struct Visita: Identifiable, Codable {
    var id = UUID()
    var fecha: Date
    var descripcion: String
    var imagen: String?
    var anotaciones: [Anotacion] = []
}
EOF

cat > Models/Anotacion.swift << 'EOF'
import Foundation

struct Anotacion: Identifiable, Codable {
    var id = UUID()
    var texto: String
    var imagen: String?
}
EOF

# Clase de datos compartida
cat > Utils/DatosObras.swift << 'EOF'
import Foundation

class DatosObras: ObservableObject {
    @Published var obras: [Obra] = []
}
EOF

# Tema de la app (colores HG)
cat > Utils/AppTheme.swift << 'EOF'
import SwiftUI

struct AppTheme {
    static let colorPrincipal = Color(red: 225/255, green: 6/255, blue: 0/255)
    static let colorFondo = Color(red: 240/255, green: 240/255, blue: 240/255)
}
EOF

# Vista principal
cat > Views/ListaObrasView.swift << 'EOF'
import SwiftUI

struct ListaObrasView: View {
    @EnvironmentObject var datos: DatosObras
    @State private var mostrandoNuevaObra = false

    var body: some View {
        NavigationView {
            List {
                ForEach(datos.obras) { obra in
                    NavigationLink(destination: DetalleObraView(obra: obra)) {
                        Text(obra.nombre)
                            .font(.headline)
                    }
                }
                .onDelete { indexSet in
                    datos.obras.remove(atOffsets: indexSet)
                }
            }
            .navigationTitle("Obras")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        mostrandoNuevaObra = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppTheme.colorPrincipal)
                    }
                }
            }
            .sheet(isPresented: $mostrandoNuevaObra) {
                EditarObraView { nuevaObra in
                    datos.obras.append(nuevaObra)
                    mostrandoNuevaObra = false
                }
            }
        }
    }
}
EOF

# Vista para crear/editar obra
cat > Views/EditarObraView.swift << 'EOF'
import SwiftUI

struct EditarObraView: View {
    @Environment(\.dismiss) var dismiss
    @State private var nombre = ""
    @State private var direccion = ""
    var onGuardar: (Obra) -> Void

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
                        let nueva = Obra(nombre: nombre, direccion: direccion)
                        onGuardar(nueva)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }
}
EOF

# Detalle de la obra
cat > Views/DetalleObraView.swift << 'EOF'
import SwiftUI

struct DetalleObraView: View {
    @State var obra: Obra
    @EnvironmentObject var datos: DatosObras
    @State private var mostrandoNuevaVisita = false

    var body: some View {
        List {
            Section(header: Text("Visitas")) {
                ForEach(obra.visitas) { visita in
                    NavigationLink(destination: DetalleVisitaView(visita: visita)) {
                        VStack(alignment: .leading) {
                            Text(visita.fecha, style: .date)
                                .font(.headline)
                            Text(visita.descripcion)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(obra.nombre)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    mostrandoNuevaVisita = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(AppTheme.colorPrincipal)
                }
            }
        }
        .sheet(isPresented: $mostrandoNuevaVisita) {
            EditarVisitaView { nueva in
                obra.visitas.append(nueva)
                if let index = datos.obras.firstIndex(where: { $0.id == obra.id }) {
                    datos.obras[index] = obra
                }
                mostrandoNuevaVisita = false
            }
        }
    }
}
EOF

# Info.plist
cat > Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDisplayName</key>
  <string>GestionObrasHG</string>
  <key>CFBundleIdentifier</key>
  <string>com.hg.GestionObrasHG</string>
  <key>CFBundleName</key>
  <string>GestionObrasHG</string>
  <key>UILaunchStoryboardName</key>
  <string>Main</string>
  <key>UIRequiresFullScreen</key>
  <true/>
  <key>UIStatusBarHidden</key>
  <false/>
  <key>UISupportedInterfaceOrientations</key>
  <array>
    <string>UIInterfaceOrientationPortrait</string>
  </array>
</dict>
</plist>
EOF

# Crear proyecto Xcode
xcodebuild -create-xcodeproj -projectName GestionObrasHG

cd ..

echo "✅ Proyecto GestionObrasHG generado correctamente."
echo "📦 Listo para compilar o incluir en GitHub Actions."
