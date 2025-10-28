#!/bin/bash
set -e

PROYECTO="GestionObrasHG"
DESTINO="$HOME/Desktop/$PROYECTO"

echo "🧱 Creando proyecto $PROYECTO en $DESTINO..."
rm -rf "$DESTINO"
mkdir -p "$DESTINO"/{Models,Views,Helpers,Theme}

# =====================
# ARCHIVO PRINCIPAL
# =====================
cat > "$DESTINO/GestionObrasHGApp.swift" <<'EOF'
import SwiftUI

@main
struct GestionObrasHGApp: App {
    @StateObject private var datos = DatosObras()
    var body: some Scene {
        WindowGroup {
            ObrasListView()
                .environmentObject(datos)
        }
    }
}
EOF

# =====================
# MODELOS
# =====================
cat > "$DESTINO/Models/Obra.swift" <<'EOF'
import Foundation
struct Obra: Identifiable, Codable {
    var id = UUID()
    var nombre: String
    var ubicacion: String
    var descripcion: String
    var imagen: String?
    var visitas: [Visita] = []
}
EOF

cat > "$DESTINO/Models/Visita.swift" <<'EOF'
import Foundation
struct Visita: Identifiable, Codable {
    var id = UUID()
    var fecha: Date
    var descripcion: String
    var imagen: String?
    var anotaciones: [Anotacion] = []
}
EOF

cat > "$DESTINO/Models/Anotacion.swift" <<'EOF'
import Foundation
struct Anotacion: Identifiable, Codable {
    var id = UUID()
    var texto: String
    var imagen: String?
}
EOF

cat > "$DESTINO/Models/DatosObras.swift" <<'EOF'
import Foundation
import SwiftUI

@MainActor
class DatosObras: ObservableObject {
    @Published var obras: [Obra] = [] {
        didSet { guardar() }
    }

    private let ruta = FileManager.documentsDirectory.appendingPathComponent("obras.json")

    init() { cargar() }

    func cargar() {
        guard let data = try? Data(contentsOf: ruta),
              let decoded = try? JSONDecoder().decode([Obra].self, from: data)
        else { return }
        obras = decoded
    }

    func guardar() {
        guard let data = try? JSONEncoder().encode(obras) else { return }
        try? data.write(to: ruta, options: [.atomic, .completeFileProtection])
    }
}
EOF

# =====================
# HELPERS
# =====================
cat > "$DESTINO/Helpers/FileManager+Extensions.swift" <<'EOF'
import UIKit
extension FileManager {
    static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

extension UIImage {
    func saveToDocuments(named name: String) {
        if let data = ImageCompressor.compress(self) {
            let url = FileManager.documentsDirectory.appendingPathComponent(name)
            try? data.write(to: url)
        }
    }

    static func loadFromDocuments(_ name: String) -> UIImage? {
        let url = FileManager.documentsDirectory.appendingPathComponent(name)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}
EOF

cat > "$DESTINO/Helpers/ImageCompressor.swift" <<'EOF'
import UIKit
struct ImageCompressor {
    static func compress(_ image: UIImage, maxKB: Int = 300) -> Data? {
        var compression: CGFloat = 1.0
        guard var data = image.jpegData(compressionQuality: compression) else { return nil }
        while (data.count / 1024) > maxKB && compression > 0.1 {
            compression -= 0.1
            if let newData = image.jpegData(compressionQuality: compression) { data = newData }
        }
        return data
    }
}
EOF

cat > "$DESTINO/Helpers/PDFGenerator.swift" <<'EOF'
import PDFKit
import SwiftUI

struct PDFGenerator {
    static func generarPDF(obra: Obra, visita: Visita? = nil) -> URL? {
        let nombreArchivo = visita != nil ? "Visita-\(visita!.id).pdf" : "Obra-\(obra.id).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(nombreArchivo)
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595, height: 842))

        do {
            try renderer.writePDF(to: url) { ctx in
                ctx.beginPage()
                let titulo = visita != nil ? "Visita de obra" : "Informe completo de obra"
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 22),
                    .foregroundColor: UIColor.red
                ]
                titulo.draw(at: CGPoint(x: 40, y: 40), withAttributes: attrs)
            }
            return url
        } catch {
            print("Error generando PDF:", error.localizedDescription)
            return nil
        }
    }
}
EOF

# =====================
# THEME
# =====================
cat > "$DESTINO/Theme/AppTheme.swift" <<'EOF'
import SwiftUI
struct AppTheme {
    static let colorPrincipal = Color(red: 0.8, green: 0.1, blue: 0.1)
    static let colorFondo = Color(white: 0.95)
}
EOF

# =====================
# VISTAS
# =====================
cat > "$DESTINO/Views/ObrasListView.swift" <<'EOF'
import SwiftUI

struct ObrasListView: View {
    @EnvironmentObject var datos: DatosObras
    @State private var nuevaObra = false

    var body: some View {
        NavigationView {
            List {
                ForEach(datos.obras) { obra in
                    NavigationLink(destination: DetalleObraView(obra: binding(for: obra))) {
                        VStack(alignment: .leading) {
                            Text(obra.nombre).font(.headline)
                            Text(obra.ubicacion).font(.subheadline).foregroundColor(.gray)
                        }
                    }
                }
                .onDelete { indices in datos.obras.remove(atOffsets: indices) }
            }
            .navigationTitle("Obras")
            .toolbar {
                Button(action: { nuevaObra = true }) {
                    Label("Añadir", systemImage: "plus")
                }
            }
            .sheet(isPresented: $nuevaObra) {
                EditarObraView { nueva in datos.obras.append(nueva) }
            }
        }
    }

    func binding(for obra: Obra) -> Binding<Obra> {
        guard let index = datos.obras.firstIndex(where: { $0.id == obra.id }) else {
            fatalError("Obra no encontrada")
        }
        return $datos.obras[index]
    }
}
EOF

cat > "$DESTINO/Views/DetalleObraView.swift" <<'EOF'
import SwiftUI

struct DetalleObraView: View {
    @Binding var obra: Obra
    @State private var nuevaVisita = false

    var body: some View {
        VStack {
            List {
                ForEach(obra.visitas) { visita in
                    NavigationLink(destination: DetalleVisitaView(obra: $obra, visita: binding(for: visita))) {
                        Text(visita.descripcion)
                    }
                }
                .onDelete { obra.visitas.remove(atOffsets: $0) }
            }
            .toolbar {
                Button(action: { nuevaVisita = true }) {
                    Label("Añadir visita", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $nuevaVisita) {
            EditarVisitaView { nueva in obra.visitas.append(nueva) }
        }
        .navigationTitle(obra.nombre)
    }

    func binding(for visita: Visita) -> Binding<Visita> {
        guard let index = obra.visitas.firstIndex(where: { $0.id == visita.id }) else {
            fatalError("Visita no encontrada")
        }
        return $obra.visitas[index]
    }
}
EOF

cat > "$DESTINO/Views/EditarObraView.swift" <<'EOF'
import SwiftUI

struct EditarObraView: View {
    @Environment(\.dismiss) var dismiss
    @State private var nombre = ""
    @State private var ubicacion = ""
    @State private var descripcion = ""

    var onGuardar: (Obra) -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Nombre", text: $nombre)
                TextField("Ubicación", text: $ubicacion)
                TextField("Descripción", text: $descripcion)
            }
            .navigationTitle("Nueva Obra")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        let obra = Obra(nombre: nombre, ubicacion: ubicacion, descripcion: descripcion)
                        onGuardar(obra)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar", action: { dismiss() })
                }
            }
        }
    }
}
EOF

# =====================
# ZIP FINAL
# =====================
cd "$HOME/Desktop"
zip -r "${PROYECTO}.zip" "$PROYECTO" > /dev/null
echo "📦 Proyecto completo listo: $HOME/Desktop/${PROYECTO}.zip"
echo "✅ Abre el ZIP en Xcode 14.3, compila y prueba en simulador o genera IPA sin firmar."
