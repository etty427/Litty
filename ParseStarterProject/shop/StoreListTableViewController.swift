//
//  StoreListTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Ty rainey on 7/25/18.
//  Copyright © 2018 Parse. All rights reserved.
//

import UIKit
import Alamofire

class StoreListTableViewController: UITableViewController {

    var drinks: [Drink] = []
    @IBOutlet var loadingView: UIView!
    
        override func viewDidLoad() {
            super.viewDidLoad()
            showLoadingScreen()
            navigationItem.title = "Select Drinks"
            fetchInventory { drinks in
                guard drinks != nil else { return }
                self.drinks = drinks!
                self.tableView.reloadData()
                self.hideLoadingScreen()
            }
        }
    func showLoadingScreen() {
        loadingView.bounds.size.width = view.bounds.width - 25
        loadingView.bounds.size.height = view.bounds.height - 25
        loadingView.layer.cornerRadius = 30
        loadingView.center = view.center
        
        UIView.animate(withDuration: 0.03, delay:0.05, options: [], animations: {
            self.loadingView.alpha = 1
        }) { (success) in
            //self.hideLoadingScreen()
        }
        view.addSubview(loadingView)
    }
    
    func hideLoadingScreen() {
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.loadingView.transform = CGAffineTransform(translationX: 0, y: 10)
        }) { (success) in
            UIView.animate(withDuration: 0.3, animations: {
                //self.loadingView.transform = CGAffineTransform(translationX: 0, y: -800)
                self.loadingView.alpha = 0
            })
        }
    }
    
        private func fetchInventory(completion: @escaping ([Drink]?) -> Void) {
            Alamofire.request("https://littyct.herokuapp.com/inventory", method: .get).validate().responseJSON { response in
                    guard response.result.isSuccess else { return completion(nil) }
                    guard let rawInventory = response.result.value as? [[String: Any]?] else { return completion(nil) }
                let inventory = rawInventory.compactMap { drinkDict -> Drink? in
                        var data = drinkDict!
                        data["image"] = UIImage(named: drinkDict!["image"] as! String)
                        return Drink(data: data)
                    }
                    completion(inventory)
                    
            }
        }
        @IBAction func ordersButtonPressed(_ sender: Any) {
            performSegue(withIdentifier: "orders", sender: nil)
        }
        override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return drinks.count
        }
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Pizza", for: indexPath) as! DrinkTableViewCell
            cell.name.text = drinks[indexPath.row].name
            cell.drinkImageView.image = drinks[indexPath.row].image
            cell.amount.text = "$\(drinks[indexPath.row].amount) + tax"
            cell.descriptionLabel.text = drinks[indexPath.row].description
            return cell
        }
        override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 120.0
        }
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "pizza", sender: self.drinks[indexPath.row] as Drink)
        }
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "pizza" {
                guard let vc = segue.destination as? DrinksViewController else { return }
                vc.drink = sender as? Drink
            }
        }
}
