import Foundation
import CoreData

@objc(Anotacion)
public class Anotacion: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var texto: String?
    @NSManaged public var fecha: Date?
    @NSManaged public var visita: Visita?
}
