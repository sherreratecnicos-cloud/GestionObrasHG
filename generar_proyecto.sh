#!/bin/bash
set -e

# === CONFIGURACIÓN INICIAL ===
PROYECTO="GestionObrasHG"
DESTINO="$GITHUB_WORKSPACE/$PROYECTO"

echo "🧱 Creando proyecto $PROYECTO en $DESTINO..."
rm -rf "$DESTINO"
mkdir -p "$DESTINO"/{Models,Views,Helpers,Theme}

# === FUNCIÓN AUXILIAR PARA CREAR ARCHIVOS ===
crear() {
cat <<'EOF' > "$DESTINO/$1"
$2
EOF
echo "✅ Creado $1"
}

# === ARCHIVOS DEL PROYECTO ===
# (Aquí insertas todo tu contenido de archivos como antes, ejemplo:)
crear "GestionObrasHGApp.swift" '
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
'

# ... resto de archivos Models, Helpers, Theme (igual que tu script original)

# === ZIP FINAL ===
cd "$GITHUB_WORKSPACE"
zip -r "${PROYECTO}.zip" "$PROYECTO" > /dev/null
echo "📦 Proyecto completo generado en: $GITHUB_WORKSPACE/${PROYECTO}.zip"
