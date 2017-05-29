//
//  ViewController.swift
//  MisHabitos
//
//  Created by Arnau Timoneda Heredia on 5/12/16.
//  Copyright © 2016 Arnau Timoneda Heredia. All rights reserved.
//

import UIKit

class ViewController : UIViewController {

    @IBOutlet weak var nuevoHabito: UIBarButtonItem!
    @IBOutlet weak var tablaHabitos: UITableView!
    var habitos: [Habito] = []
    var today: Date = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        /****** Datos test ********/
    

        /****** Fin Datos test ********/
        self.habitos = HabitosFactory.sharedInstance.getHabitos(completed: false)

        self.tablaHabitos.backgroundColor = self.view.backgroundColor
        self.tablaHabitos.tableFooterView = UIView(frame: CGRect.zero)
        
        if(self.esDiaNuevo()) {
            actualizarHabitos()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Muestra un AlertView que permite añadir un hábito a nuestro array de hábitos y lo guarda en Core Data.
    @IBAction func añadirHabito(_ sender: Any) {
        //Muestra un pop up para introducir un nuevo hábito. Los hábitos empiezan el día 1
        let alertController : UIAlertController = UIAlertController(title: "Nuevo Hábito", message: "Introduce el nombre del nuevo hábito a establecer", preferredStyle: .alert)
        
        //Campo de texto
        alertController.addTextField { (nombreTextField : UITextField!) -> Void in
            nombreTextField.placeholder = "Hábito"
        }
        //Acción cancelar
        let anAction2 : UIAlertAction = UIAlertAction(title: "Cancelar", style: .destructive, handler: nil)
        alertController.addAction(anAction2)

        //Acción aceptar, crear habito y guardarlo en core data
        let anAction : UIAlertAction = UIAlertAction(title: "Aceptar", style: .default, handler: {
            (action) in
            if let nombreHabito = (alertController.textFields![0] as UITextField).text {
                if !nombreHabito.isEmpty {
                    let nuevoHabito:Habito = HabitosFactory.sharedInstance.addHabitoWith(nombre: nombreHabito, fechaInicio: self.today, diaActual: 1 as NSNumber, habitoEstablecido: false, hoyHecho: false, dias: [], ultimaModificacion: self.today, finalizado: false)
                    self.habitos.append(nuevoHabito)
                    let index : IndexPath = IndexPath(row: self.habitos.count - 1 , section: 0)
                    self.tablaHabitos.insertRows(at:  [index], with: .fade)
                }
            }
        })
        alertController.addAction(anAction)

        present(alertController, animated: true, completion: nil)
    }
    
    //Muestra un AlertView con mensajes dependiendo si hemos completado o no el hábito.
    func habitoCompletado(habito:Habito, index:Int, success:Bool) {
        var message:String
        var title:String
        habito.finalizado = true;
        if success{
            title = "Muchas Felicidades!"
            message = "Has completado el hábito: \(habito.nombre!)."
        } else {
            title = "Lástima!"
            message = "No has podido completar el hábito: \(habito.nombre!)."
        }
        let alertController : UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let anAction : UIAlertAction = UIAlertAction(title: "Aceptar", style: .destructive, handler:{ action in
            self.habitos.remove(at: index)
            HabitosFactory.sharedInstance.guardar()
            self.tablaHabitos.reloadData()
            self.actualizarHabitos()
        })
        alertController.addAction(anAction)
        
        present(alertController, animated: true, completion: nil)
    }

    //Actualiza el estado actual de los hábitos.
    @IBAction func actualizarHabitos() {
        //Ha pasado un dia(o más), revisamos los habitos para actualizar el dia actual, poner el hecho hoy a false y comprovar si vamos bien o no(Actualizar el array de dias)
        for i in 0..<habitos.count {
            let h:Habito = habitos[i]
            h.actualizarDiaActualDeHabito(date: self.today)
            //Metemos tantos falses como dias han pasado sin abrir la app
            
            if(!h.hoyHecho){
                for _ in 0..<h.getDiasSinAbrir() - 1 {
                    h.addDay(day:false)
                }
                
            } else if (h.hoyHecho && h.getDiasSinAbrir() > 1){
                for _ in 0..<h.getDiasSinAbrir() - 1  {
                    h.addDay(day: false)
                }
            }
            
            h.hoyHecho = false
            h.ultimaModificacion = self.today
            
            if h.getTotalDays() >= 21 {
                self.habitoCompletado(habito: h, index: i, success: false)
                break;
            }
            self.tablaHabitos.reloadData()
            HabitosFactory.sharedInstance.guardar()

        }

    }
    
    //Detecta si ha pasado un día desde la última vez que se abrió la aplicación.
    func esDiaNuevo() -> Bool {
        var result = true
        if self.habitos.count > 0 {
            let h:Habito = habitos[0]
            let order = Calendar.current.compare(self.today, to: h.ultimaModificacion, toGranularity: .day)
            if order == .orderedSame{
                result = false
            }
        }
        return result
    }
    
    
    @IBAction func activarHabito(_ sender: UISwitch) {
        
        let hab = self.habitos[sender.tag]
        if sender.isOn {
            hab.addDay(day: true)
            hab.hoyHecho = true
            
            if(hab.diaActual as Int == 21){
                self.habitoCompletado(habito: hab, index: sender.tag, success:true)
            }
            
        }else{
            hab.removeLastDay()
            hab.hoyHecho = false
        }
        let index : IndexPath = IndexPath(row: sender.tag , section: 0)
        self.tablaHabitos.reloadRows(at: [index], with: .fade)
        HabitosFactory.sharedInstance.guardar()
    }
}

//La clase hereda los métodos de UITableViewController y así podemos customizarlos
extension ViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //Número de secciones de la tabla.
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Número de celdas que va a tener la tabla.
        return self.habitos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Función que se ejecuta para rellenar cada celda.
        let habito = habitos[indexPath.row]
        let cellId = "habitoCell"
        
        let cell = self.tablaHabitos.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! HabitoCell
        cell.habitoCell = habito
        cell.nombreHabito.text = habito.nombre
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        cell.fechaInicio.text = dateFormatter.string(from: (habito.fechaInicio!))
        cell.fechaFin.text = dateFormatter.string(from: habito.calcularFechaFin(fecha: habito.fechaInicio))
        let progreso:Float = Float(habito.getDaysDone()) / Float(21)
        
        cell.botonHecho.tag = indexPath.row
        cell.botonHecho.isOn = habito.hoyHecho

        
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //Esta función habilita el slide a la izquierda de cada celda y muestra el botón para que pueda ser eliminada.
        if editingStyle == .delete{
            HabitosFactory.sharedInstance.delete(habito: self.habitos[indexPath.row])
            self.habitos.remove(at: indexPath.row)
            self.tablaHabitos.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
