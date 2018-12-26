//
//  OrdersViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Ty rainey on 7/25/18.
//  Copyright © 2018 Parse. All rights reserved.
//

import UIKit
class OrderViewController: UIViewController {
    var order: Order?
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var activityView: ActivityIndicator!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = order?.drink.name
        activityView.startLoading()
        switch order!.status {
        case .pending:
            status.text = "Processing Order"
        case .accepted:
            status.text = "Preparing Order"
        case .dispatched:
            status.text = "Order is on its way!"
        case .delivered:
            status.text = "Order delivered"
            activityView.strokeColor = UIColor.green
            activityView.completeLoading(success: true)
        }
    }
}
