import Foundation
import CoreData

@objc(Obra)
public class Obra: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var nombre: String?
    @NSManaged public var ubicacion: String?
    @NSManaged public var visitas: Set<Visita>?
}
