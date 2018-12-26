//
//  PizzaTableViewCell.swift
//  ParseStarterProject-Swift
//
//  Created by Ty rainey on 7/25/18.
//  Copyright © 2018 Parse. All rights reserved.
//

import UIKit

class DrinkTableViewCell: UITableViewCell {
    
    @IBOutlet weak var drinkImageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var amount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
