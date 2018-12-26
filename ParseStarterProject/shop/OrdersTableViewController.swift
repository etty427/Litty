//
//  OrdersTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Ty rainey on 7/25/18.
//  Copyright © 2018 Parse. All rights reserved.
//

import UIKit
import Alamofire



class OrdersTableViewController: UITableViewController, ViewPassesData {
    var orderArray: [Drink] = []
    

    
    
    var orders: [Order] = []
    var refresher: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresher = UIRefreshControl()
        tableView.addSubview(refresher)
        refresher.addTarget(self, action: #selector(fetchOrder), for: .valueChanged)
        refresher.attributedTitle = NSAttributedString(string: "Refreshing Order Status....")
        navigationItem.title = "Orders"
        fetchOrders { orders in
            self.orders = orders!
            self.tableView.reloadData()
        }
        self.tableView.reloadData()
    }
    private func fetchOrders(completion: @escaping([Order]?) -> Void) {
        Alamofire.request("https://littyct.herokuapp.com/orders").validate().responseJSON { response in
            guard response.result.isSuccess else { return completion(nil) }
            guard let rawOrders = response.result.value as? [[String: Any]?] else { return completion(nil) }
            let orders = rawOrders.compactMap { ordersDict -> Order? in
                guard let orderId = ordersDict!["id"] as? String,
                    let orderStatus = ordersDict!["status"] as? String,
                    var drink = ordersDict!["drink"] as? [String: Any] else { return nil }
                drink["image"] = UIImage(named: drink["image"] as! String)
                return Order(
                    id: orderId,
                    drink: Drink(data: drink),
                    status: OrderStatus(rawValue: orderStatus)!
                )
            }
            completion(orders)
        }
    }
    @objc func fetchOrder() {
        fetchOrders { orders in
            self.orders = orders!
            self.tableView.reloadData()
        }
        refresher.endRefreshing()
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "order", for: indexPath)
        let order = orders[indexPath.row]
        cell.textLabel?.text = order.drink.name
        cell.imageView?.image = order.drink.image
        cell.detailTextLabel?.text = "$\(order.drink.amount) - \(order.status.rawValue)"
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "order", sender: orders[indexPath.row] as Order)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "order" {
            guard let vc = segue.destination as? OrderViewController else { return }
            vc.order = sender as? Order
        }
    }
}
