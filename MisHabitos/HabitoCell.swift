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
}
