 import SwiftUI

-struct VisitasView: View {
-    @ObservedObject var obra: Obra?
+struct VisitasView: View {
+    // ✅ Solución: no puede ser opcional con @ObservedObject
+    // Si quieres que sea opcional, elimina @ObservedObject
+    @ObservedObject var obra: Obra
     
     var body: some View {
         List {
-            ForEach(obra?.visitas ?? [], id: \.id) { visita in
+            // ✅ No hace falta opcional: obra.visitas siempre existe
+            ForEach(obra.visitas, id: \.id) { visita in
                 Text(visita.descripcion)
             }
         }
         .navigationTitle("Visitas")
     }
 }
