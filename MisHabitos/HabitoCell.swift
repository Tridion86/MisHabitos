//
//  HabitoCell.swift
//  MisHabitos
//
//  Created by Arnau Timoneda Heredia on 11/12/16.
//  Copyright © 2016 Arnau Timoneda Heredia. All rights reserved.
//

import UIKit

class HabitoCell: UITableViewCell {
    
    var habitoCell:Habito!
    @IBOutlet weak var nombreHabito: UILabel!
    @IBOutlet weak var fechaInicio: UILabel!
    @IBOutlet weak var fechaFin: UILabel!
    @IBOutlet weak var barraProgreso: UIProgressView!
    @IBOutlet weak var botonHecho: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func habitoHecho(_ sender: UISwitch) {
        //Al activar el habito para el dia de hoy, comprovamos si el array de dias contiene el mismo numero de elementos que el dia actual, si no es asi, añadimos un true al array de dias. Si lo desactivamos, quitamos el último dia del array.
       /* print("habito marcado: \(self.habitoCell.nombre!)")
        if sender.isOn {
            self.habitoCell.dias.append(true)
            self.habitoCell.hoyHecho = true
            self.barraProgreso.progress = self.barraProgreso.progress + 0.047
        }else{
            self.habitoCell.dias.removeLast()
            self.habitoCell.hoyHecho = false
            self.barraProgreso.progress = self.barraProgreso.progress - 0.047
        }
        self.habitoCell.toString()*/

    }
}
