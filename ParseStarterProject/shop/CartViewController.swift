//
//  CartViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Ty rainey on 7/31/18.
//  Copyright © 2018 Parse. All rights reserved.
//

import UIKit
import Alamofire

class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var cartTavbleView: UITableView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!

    var orders: [Order] = []
    var cartArray = [String]()
    var priceArray = [NSNumber]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        fetchOrders { orders in
            self.orders = orders!
            self.cartTavbleView.reloadData()
            var sum: Double = 0.0
            for num in orders! {
                let a = Double(truncating: num.drink.amount)
                sum += a
                let tax = sum * 0.06
                let fee = 5.99
                let newSum = sum + tax + fee
                let totalSum = (newSum * 1000) / 1000
                let roundSum = round(totalSum)
                self.totalPriceLabel.text = "$\(roundSum)"
                self.taxLabel.text = "$\(tax)"
            }
        }
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "checkout", for: indexPath)
        let order = orders[indexPath.row]
        cell.textLabel?.text = order.drink.name
        cell.detailTextLabel?.text = "$\(order.drink.amount)"
        return cell
    }
    
    @IBAction func reviewCheckoutBtnPressed(_ sender: Any) {
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
    func add() {
        //add prices together
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
