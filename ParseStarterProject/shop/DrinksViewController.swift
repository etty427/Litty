//
//  PizzaViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Ty rainey on 7/25/18.
//  Copyright © 2018 Parse. All rights reserved.
//

import UIKit
import Alamofire
import PusherSwift

protocol ViewPassesData: class {
    var orderArray : [Drink] { get set }
}

class DrinksViewController: UIViewController {
    var orderArray: [String] = []
    var priceArray: [NSNumber] = []
    
    var drink: Drink?
    var order: Order?
    
 
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var drinkDescription: UILabel!
    @IBOutlet weak var drinkImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = drink!.name
        drinkImageView.image = drink!.image
        drinkDescription.text = drink!.description
        amount.text = "$\(String(describing: drink!.amount))"
        navigationItem.title = drink?.name
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        if let vc = segue.destination as? CartViewController  {
            vc.cartArray = orderArray
            vc.priceArray = priceArray
            
        }
        // Pass the selected object to the new view controller.
    }
    
    @IBAction func buyButtonPressed(_ sender: Any) {
        //orderArray.append((pizza?.name)!)
       // priceArray.append((pizza?.amount)!)
        
        let parameters = [
            "drink_id": drink!.id,
            "user_id": AppMisc.USER_ID
        ]
        Alamofire.request("https://littyct.herokuapp.com/orders", method: .post, parameters: parameters)
            .validate()
            .responseJSON { response in
                guard response.result.isSuccess else { return self.alertError() }
                guard let status = response.result.value as? [String: Bool],
                    let successful = status["status"] else { return self.alertError() }
                successful ? self.alertSuccess() : self.alertError()
        }
        performSegue(withIdentifier: "cart", sender: nil)
    }
    private func alertError() {
        return self.alert(
            title: "Purchase unsuccessful!",
            message: "Unable to complete purchase please try again later."
        )
    }
    private func alertSuccess() {
        return self.alert(
            title: "Purchase Successful",
            message: "You have ordered successfully, your order will be confirmed soon."
        )
    }
    private func alert(title: String, message: String) {
        let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertCtrl.addAction(UIAlertAction(title: "Okay", style: .cancel) { action in
            //self.navigationController?.popViewController(animated: true)
        })
        present(alertCtrl, animated: true, completion: nil)
        }
}
