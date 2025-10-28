import Foundation

extension Obra {
    var visitasArray: [Visita] {
        let set = visitas as? Set<Visita> ?? []
        return set.sorted { ($0.fecha ?? Date()) < ($1.fecha ?? Date()) }
    }
}

extension Visita {
    var anotacionesArray: [Anotacion] {
        let set = anotaciones as? Set<Anotacion> ?? []
        return set.sorted { ($0.fecha ?? Date()) < ($1.fecha ?? Date()) }
    }
}
