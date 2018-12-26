//
//  ShopsViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Ty rainey on 7/23/18.
//  Copyright © 2018 Parse. All rights reserved.
//

import UIKit
import GooglePlaces
import MapKit

class ShopsViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, CLLocationManagerDelegate {
    @IBOutlet weak var shopsTableView: UITableView!
    
    var placesClient: GMSPlacesClient!
    var placesArray:[Dictionary<String,AnyObject>] = Array()
    var resultsController: UISearchController!
    var shop = "liquor meriden"
    let locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        placesClient = GMSPlacesClient.shared()
        shopsTableView.dataSource = self
        shopsTableView.contentInset.top = 10
        getShops()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location?.coordinate {
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shop")
        let place = placesArray[indexPath.row]
        
        if let nameLabel = cell?.contentView.viewWithTag(1) as? UILabel {
            nameLabel.text = "\(place["name"] as! String)"
        }
        if let addressLabel = cell?.contentView.viewWithTag(2) as? UILabel {
            addressLabel.text = "\(place["formatted_address"] as! String)"
        }
        if let ratingsLabel = cell?.contentView.viewWithTag(3) as? UILabel {
            ratingsLabel.text = "Ratings: \(place["rating"] as! Double)"
        }
        if let storeHoursLabel = cell?.contentView.viewWithTag(4) as? UILabel {
            if let storeHours = place["opening_hours"] as? Dictionary<String,AnyObject> {
            let storeStatus = storeHours["open_now"] as? Bool
                if storeStatus == true {
                    storeHoursLabel.text = "Store is open"
                    storeHoursLabel.textColor = .blue
                } else  {
                    storeHoursLabel.text = "Store is closed"
                    storeHoursLabel.textColor = .red
                    }
            }
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func getShops() {
        var getShopsApi = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(shop)&radius=10000&key=AIzaSyAGnITomPNjwl1FYmrR-0xmamHwLPUs5-A"
        getShopsApi = getShopsApi.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        var urlRequest = URLRequest(url: URL(string: getShopsApi)!)
        urlRequest.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil {
                
                if let responseData = data {
                 let jsonDict = try? JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                if let dict = jsonDict as? Dictionary<String,AnyObject> {
                    if let results = dict["results"] as? [Dictionary<String,AnyObject>] {
                        //print(results)
                        for dct in results {
                            self.placesArray.append(dct)
                        }
                        DispatchQueue.main.async {
                            self.shopsTableView.reloadData()
                        }
                    }
                }
            }
            } else {
                print("Error: ",error)
                print("No results")
            }
        }
        task.resume()
    }
    
}




















