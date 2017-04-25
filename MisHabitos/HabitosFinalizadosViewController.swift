//
//  HabitosFinalizadosViewController.swift
//  MisHabitos
//
//  Created by Arnau Timoneda Heredia on 14/4/17.
//  Copyright © 2017 Arnau Timoneda Heredia. All rights reserved.
//

import UIKit
import CoreData

class HabitosFinalizadosViewController: UIViewController {
    
    @IBOutlet weak var tablaHabitosFinalizados: UITableView!
    
    var habitosFinalizados: [Habito] = []
    //var managedContext: NSManagedObjectContext? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("nueva vista")
        habitosFinalizados = HabitosFactory.sharedInstance.getHabitos(completed: true)
        
        self.tablaHabitosFinalizados.backgroundColor = self.view.backgroundColor
        self.tablaHabitosFinalizados.tableFooterView = UIView(frame: CGRect.zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        habitosFinalizados = HabitosFactory.sharedInstance.getHabitos(completed: true)
        self.tablaHabitosFinalizados.reloadData()
    }
    
}

extension HabitosFinalizadosViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //Número de secciones de la tabla.
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Número de celdas que va a tener la tabla.
        return self.habitosFinalizados.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Función que se ejecuta para rellenar cada celda.
        let habito = habitosFinalizados[indexPath.row]
        let cellId = "habitoCell"
        
        let cell = self.tablaHabitosFinalizados.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! HabitoCell

        cell.habitoCell = habito
        cell.nombreHabito.text = habito.nombre
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        cell.fechaInicio.text = dateFormatter.string(from: (habito.fechaInicio!))
        cell.fechaFin.text = dateFormatter.string(from: habito.calcularFechaFin(fecha: habito.fechaInicio))
        let progreso:Float = Float(habito.getDaysDone()) / Float(21)
        
        //cell.botonHecho.tag = indexPath.row
        //cell.botonHecho.isOn = habito.hoyHecho
        
        
        //Diseño celda
        //cell.layer.cornerRadius = 10
        
        
        //Barra Progreso
        cell.barraProgreso.layer.cornerRadius = 5
        cell.barraProgreso.layer.borderWidth = 1
        cell.barraProgreso.layer.masksToBounds = true
        cell.barraProgreso.clipsToBounds = true
        cell.barraProgreso.layer.borderColor = UIColor.blue.cgColor
        
        if !habito.esUnHabitoPerfecto() {
            cell.barraProgreso.tintColor = UIColor.red
        }else{
            cell.barraProgreso.tintColor = UIColor.green
            
        }
        cell.barraProgreso.progress = progreso
        
        print("DIBUJO2: \(cell.nombreHabito.text)")

        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //Esta función habilita el slide a la izquierda de cada celda y muestra el botón para que pueda ser eliminada.
        if editingStyle == .delete{
            HabitosFactory.sharedInstance.delete(habito: self.habitosFinalizados[indexPath.row])
            self.habitosFinalizados.remove(at: indexPath.row)
            self.tablaHabitosFinalizados.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
