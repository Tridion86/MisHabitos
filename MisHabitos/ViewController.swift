//
//  ViewController.swift
//  MisHabitos
//
//  Created by Arnau Timoneda Heredia on 5/12/16.
//  Copyright © 2016 Arnau Timoneda Heredia. All rights reserved.
//

import UIKit
import CoreData

class ViewController : UIViewController {

    @IBOutlet weak var nuevoHabito: UIBarButtonItem!
    @IBOutlet weak var tablaHabitos: UITableView!
    var habitos: [Habito] = []
    var today: Date = Date()

    var managedContext: NSManagedObjectContext? = nil
    var diaMenys: Date = Date().addingTimeInterval(-86400)
    var fetchResultsController: NSFetchedResultsController<Habito>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /****** Datos test ********/
    
        
        
        /****** Fin Datos test ********/
        
        /* Load managedContext CORE DATA */
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.managedContext = appDelegate!.persistentContainer.viewContext
        /* END CORE DATA */
        
        let fetchRequest : NSFetchRequest<Habito> = NSFetchRequest(entityName: "Habito")
        let sortDescriptor = NSSortDescriptor(key: "fechaInicio", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        //Obtenemos los habitos de core data
        self.fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedContext!,sectionNameKeyPath: nil, cacheName: nil)
        self.fetchResultsController.delegate = self
        do{
            try fetchResultsController.performFetch()
            self.habitos = fetchResultsController.fetchedObjects!
        } catch {
            print("No se han podido recuperar los objetos de CoreData")
        }

        self.tablaHabitos.backgroundColor = self.view.backgroundColor
        self.tablaHabitos.tableFooterView = UIView(frame: CGRect.zero)
        
        if(self.esDiaNuevo()) {
            print("ES DIA NUEVO")
            actualizarHabitos()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
                    let nuevoHabito:Habito = NSEntityDescription.insertNewObject(forEntityName: "Habito", into: self.managedContext!) as! Habito
                    nuevoHabito.nombre = nombreHabito
                    nuevoHabito.fechaInicio = self.today
                    nuevoHabito.diaActual = 1 as NSNumber
                    nuevoHabito.habitoEstablecido = false
                    nuevoHabito.hoyHecho = false
                    nuevoHabito.dias = []
                    nuevoHabito.ultimaModificacion = self.today
                    self.habitos.append(nuevoHabito)
                    self.guardar()
                }
            }
        })
        alertController.addAction(anAction)

        present(alertController, animated: true, completion: nil)
    }
    
    func habitoCompletado(habito:Habito, index:Int, success:Bool) {
        var message:String
        var title:String
        if success{
            title = "Muchas Felicidades!"
            message = "Has completado el hábito: \(habito.nombre!)."
        } else {
            title = "Lástima!"
            message = "No has podido completar el hábito: \(habito.nombre!)."
        }
        let alertController : UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let anAction : UIAlertAction = UIAlertAction(title: "Aceptar", style: .destructive, handler:{ action in
            self.managedContext?.delete(self.habitos[index])
            self.habitos.remove(at: index)
            self.guardar()
            if(!success){
                self.actualizarHabitos()
            }
        })
        alertController.addAction(anAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func guardar(){
        //Guarda el managed context para persistir los datos
        do{
            try self.managedContext?.save()
            
        } catch {
            print("Error al guardar el managed Context")
        }
    }

    @IBAction func actualizarHabitos() {
        //Ha pasado un dia(o más), revisamos los habitos para actualizar el dia actual, poner el hecho hoy a false y comprovar si vamos bien o no(Actualizar el array de dias)
        for i in 0..<habitos.count {
            let h:Habito = habitos[i]
            print("actualizamos el habito: \(h.nombre)")
            h.actualizarDiaActualDeHabito(date: self.today)
            //Metemos tantos falses como dias han pasado sin abrir la app
            
            if(!h.hoyHecho){
                for _ in 0..<h.getDiasSinAbrir() - 1 {
                    print("Los dias sin abrir son: \(h.getDiasSinAbrir())")
                    h.dias.append(false)
                }
                
            } else if (h.hoyHecho && h.getDiasSinAbrir() > 1){
                for _ in 0..<h.getDiasSinAbrir() - 1  {
                    print("Los dias sin abrir pet son: \(h.getDiasSinAbrir())")
                    h.dias.append(false)
                }
            }
            
            print("count array = \(h.dias.count)")
            print("array de dias que evaluamos:: \(h.dias)")
            if h.esUnHabitoPerfecto(){
                print("Vamos bien con el habito: \(h.nombre!), y hoyHecho: \(h.hoyHecho)")
                //Sino, hemos fracasado con el habito.
            }else{
                
                print("hemos fracasdo con el hábito: \(h.nombre!), y hoyHecho: \(h.hoyHecho)")
                //indexToRemove.append(index)
            }
            h.hoyHecho = false
            h.ultimaModificacion = self.today
            
            if h.dias.count >= 21 {
                self.habitoCompletado(habito: h, index: i, success: false)
                break;
            }
            print("DIA ACTUAL: \(h.diaActual) Y la longitud del array es: \(h.dias.count)")

        }

    }
    
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
    
    //MARK: - Test methods
    
    @IBAction func activarHabito(_ sender: UISwitch) {
        print("el habito pinchado es::: \(self.habitos[sender.tag].nombre)")
        
        let hab = self.habitos[sender.tag]
        
        if sender.isOn {
            hab.dias.append(true)
            hab.hoyHecho = true
            
            if(hab.diaActual as Int == 21){
                self.habitoCompletado(habito: hab, index: sender.tag, success:true)
            }
            
        }else{
            hab.dias.removeLast()
            hab.hoyHecho = false

        }
    }
    @IBAction func botonTest(_ sender: Any) {
        self.today = self.today.addingTimeInterval(86400 * 1)
    }
    @IBAction func actualizarDatos(_ sender: Any) {
        self.viewDidLoad()
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
        
        print("DIBUJO: \(cell.nombreHabito.text)")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //Esta función habilita el slide a la izquierda de cada celda y muestra el botón para que pueda ser eliminada.
        if editingStyle == .delete{
            self.managedContext?.delete(self.habitos[indexPath.row])
            self.habitos.remove(at: indexPath.row)
            self.guardar()
        }
    }
    
}

extension ViewController : NSFetchedResultsControllerDelegate{
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tablaHabitos.beginUpdates()
        //self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                self.tablaHabitos.insertRows(at:  [newIndexPath], with: .fade)
                self.tablaHabitos.reloadData()
                print("insert")
            }
        case .update:
            if let indexPath = indexPath {
                self.tablaHabitos.reloadRows(at: [indexPath], with: .fade)
                self.guardar()
                print("Update")
            }
        case .delete:
            if let indexPath = indexPath {
                self.tablaHabitos.deleteRows(at: [indexPath], with: .fade)
                self.tablaHabitos.reloadData()
                print("delete")
            }
        case .move:
            if let _ = indexPath, let _ = newIndexPath {
                //self.tablaHabitos.moveRow(at: indexPath, to: newIndexPath)
                print("move")
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tablaHabitos.endUpdates()
    }
}
