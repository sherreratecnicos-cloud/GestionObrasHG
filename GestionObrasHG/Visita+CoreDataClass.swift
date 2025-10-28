import Foundation
import CoreData

@objc(Visita)
public class Visita: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var fecha: Date?
    @NSManaged public var observaciones: String?
    @NSManaged public var obra: Obra?
    @NSManaged public var anotaciones: Set<Anotacion>?
}
