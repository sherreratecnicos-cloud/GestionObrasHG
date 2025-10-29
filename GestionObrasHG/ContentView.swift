 import SwiftUI

 struct ContentView: View {
     var body: some View {
         NavigationView {
             VStack(spacing: 20) {
                 NavigationLink("Obras") {
                     ObrasView()
                 }
-                NavigationLink("Anotaciones") {
-                    AnotacionesView()
-                }
+                // ✅ Se elimina o se protege esta vista, ya que AnotacionesView no existe
+                // Si tienes la vista creada, asegúrate de que el archivo esté incluido en el target
+                // NavigationLink("Anotaciones") { AnotacionesView() }
+
+                Text("Gestión de obras HG")
+                    .font(.headline)
+                    .foregroundColor(.secondary)
             }
             .navigationTitle("Gestión de Obras")
         }
     }
 }
