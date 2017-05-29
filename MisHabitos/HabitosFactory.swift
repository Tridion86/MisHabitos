//
//  HabitosFactory.swift
//  MisHabitos
//
//  Created by Arnau Timoneda Heredia on 18/4/17.
//  Copyright © 2017 Arnau Timoneda Heredia. All rights reserved.
//

import UIKit
import CoreData

class HabitosFactory: NSObject {
    static let sharedInstance = HabitosFactory()
    
    var managedContext: NSManagedObjectContext? = nil
    
    override init(){
        super.init()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.managedContext = appDelegate!.persistentContainer.viewContext
    }
    
    func getHabitos(completed: Bool) -> [Habito] {
        var habitos:[Habito] = []
        
        let fetchRequest : NSFetchRequest<Habito> = NSFetchRequest(entityName: "Habito")
        fetchRequest.predicate = NSPredicate(format: "finalizado == %@", NSNumber(booleanLiteral: completed))
        let sortDescriptor = NSSortDescriptor(key: "fechaInicio", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        //Obtenemos los habitos de core data
        //self.fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedContext!,sectionNameKeyPath: nil, cacheName: nil)
        //self.fetchResultsController.delegate = self
        do{
            habitos = try self.managedContext?.fetch(fetchRequest) as [Habito]!
        } catch {
            print("No se han podido recuperar los objetos de CoreData")
        }
        
        return habitos
    }
    
    func addHabitoWith(nombre: String, fechaInicio: Date, diaActual: NSNumber, habitoEstablecido: Bool, hoyHecho:Bool, dias: [Bool], ultimaModificacion: Date, finalizado: Bool) -> Habito{
        let nuevoHabito:Habito = NSEntityDescription.insertNewObject(forEntityName: "Habito", into: self.managedContext!) as! Habito
        nuevoHabito.nombre = nombre
        nuevoHabito.fechaInicio = fechaInicio
        nuevoHabito.diaActual = diaActual
        nuevoHabito.habitoEstablecido = habitoEstablecido
        nuevoHabito.hoyHecho = hoyHecho
        nuevoHabito.setDias(dias: dias)
        nuevoHabito.ultimaModificacion = ultimaModificacion
        nuevoHabito.finalizado = finalizado
        
        self.guardar()
        return nuevoHabito
    }
    
    func delete(habito: Habito){
        self.managedContext?.delete(habito)
        self.guardar()
    }
    
    
    func guardar(){
        do{
            //Guarda el managed context para persistir los datos
            try self.managedContext?.save()
        } catch {
            print("Error al guardar el managed Context")
        }
    }
    
}
