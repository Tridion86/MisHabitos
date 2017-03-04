//
//  Habito.swift
//  MisHabitos
//
//  Created by Arnau Timoneda Heredia on 5/12/16.
//  Copyright © 2016 Arnau Timoneda Heredia. All rights reserved.
//
import Foundation
import UIKit
import CoreData

class Habito : NSManagedObject {
    @NSManaged var nombre:String!
    @NSManaged var fechaInicio:Date!
    @NSManaged var diaActual:NSNumber
    @NSManaged var habitoEstablecido:Bool
    @NSManaged var hoyHecho:Bool
    @NSManaged var dias :[Bool]!
    @NSManaged var ultimaModificacion :Date!
    
    func calcularFechaFin(fecha:Date) -> Date {
        //Añadimos 21 días a la fecha de inicio
        return fecha.addingTimeInterval(86400 * 21)
    }
    
    func actualizarDiaActualDeHabito(date:Date) {
        //Calcula los dias desde que se empezó el Hábito hasta la fecha actual,
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.day], from: calendar.startOfDay(for: self.fechaInicio), to: date)
        self.diaActual = components.day! + 1 as NSNumber
    }
    
    func esUnHabitoPerfecto() -> Bool {
        var result:Bool = true
        //Es perfecto a no ser que haya algún false en el array de dias,
        //el array está vacio y hayan pasado un dia(el primer dia de crearlo, no lo hemos hecho) ,
        //y cuando hayan pasado más días que los que hay en el array(mas de 1 dias sin abrir la app).
        if self.dias.contains(false) || (self.dias.isEmpty && self.diaActual as Int > 1) ||
            (self.diaActual as Int - self.dias.count as Int > 1){
            result = false
        }
        
        
        return result
    }

    func getDaysDone() -> Int {
        var result:Int = 0
        for d in self.dias {
            if d {
                result += 1
            }
        }
        return result
    }
    
    func getDiasSinAbrir() -> Int {
        return self.diaActual as Int - self.dias.count
    }
    
    func toString(){
        print("El habito: \(self.nombre!) con fecha de inicio \(self.fechaInicio!), va por el dia \(self.diaActual). array de dias: \(self.dias!), y hoy hecho: \(self.hoyHecho)")
    }

}
