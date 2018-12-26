//
//  Order.swift
//  ParseStarterProject-Swift
//
//  Created by Ty rainey on 7/25/18.
//  Copyright © 2018 Parse. All rights reserved.
//

import Foundation
struct Order {
    let id: String
    let drink: Drink
    var status: OrderStatus
}
enum OrderStatus: String {
    case pending = "Pending"
    case accepted = "Accepted"
    case dispatched = "Dispatched"
    case delivered = "Delivered"
}
