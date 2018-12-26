//
//  Pizza.swift
//  ParseStarterProject-Swift
//
//  Created by Ty rainey on 7/25/18.
//  Copyright © 2018 Parse. All rights reserved.
//

import UIKit
struct Drink {
    let id: String
    let name: String
    let description: String
    let amount: NSNumber
    let size: [String : Dictionary<String, Any>]?
    let image: UIImage?
    init(data: [String: Any]) {
        self.id = data["id"] as! String
        self.name = data["name"] as! String
        self.size = data["size"] as? [String : Dictionary<String, Any>]
        self.description = data["description"] as! String
        self.amount = data["amount"] as! NSNumber
        self.image = data["image"] as? UIImage
    }
}
