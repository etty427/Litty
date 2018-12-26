//
//  DriverTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Ty rainey on 7/22/18.
//  Copyright © 2018 Parse. All rights reserved.
//

import UIKit
import Parse


final class DriverTableViewController: UITableViewController,CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var requestUsernames = [String]()
    var requestLocations = [CLLocationCoordinate2D]()
    var userLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      /*  switch segue.identifier {
        case "driveLogout":
            PFUser.logOut()
            locationManager.stopUpdatingLocation()
            self.navigationController?.navigationBar.isHidden = true
            self.navigationController?.popToRootViewController(animated: true)
        case "showCustomerLocation":
            if let destination = segue.destination as? CustomerLocationViewController {
                if let row = tableView.indexPathForSelectedRow?.row {
                    destination.requestLocation = requestLocations[row]
                    destination.requestUsername = requestUsernames[row]
                }
            }
        default:
            break
        } */
        if segue.identifier == "driveLogout" {
            PFUser.logOut()
            locationManager.stopUpdatingLocation()
            self.navigationController?.navigationBar.isHidden = true
            self.navigationController?.popToRootViewController(animated: true)
        }
        else if segue.identifier == "showCustomerLocation" {
            if let destination = segue.destination as? CustomerLocationViewController {
                if let row = tableView.indexPathForSelectedRow?.row {
                    destination.requestLocation = requestLocations[row]
                    destination.requestUsername = requestUsernames[row]
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationItem.backBarButtonItem?.isEnabled = false

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location?.coordinate {
            userLocation = location
            
            let driverLocationQuery = PFQuery(className: "DriverLocation")
            driverLocationQuery.whereKey("username", equalTo: PFUser.current()?.username!)
            driverLocationQuery.findObjectsInBackground { (objects, error) in
                if let driverLocations = objects {
                    if driverLocations.count > 0 {
                    for driverLocation in driverLocations {
                        driverLocation["location"] = PFGeoPoint(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                        driverLocation.deleteInBackground()
                    }
                }
            }
                let driverLocation = PFObject(className: "DriverLocation")
                driverLocation["username"] = PFUser.current()?.username
                driverLocation["location"] = PFGeoPoint(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                driverLocation.saveInBackground()
                
            }
            let query = PFQuery(className: "DrinkRequesters")
            query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: location.latitude, longitude: location.longitude))
            query.limit = 10
            query.findObjectsInBackground { (objects, error) in
                self.requestUsernames.removeAll()
                self.requestLocations.removeAll()
                if let drinkrequests = objects {
                    for drinkrequest in drinkrequests {
                        if let username = drinkrequest["username"] as? String {
                            
                            if drinkrequest["driverRespnded"] == nil {
                            self.requestUsernames.append(username)
                            self.requestLocations.append(CLLocationCoordinate2D(latitude: (drinkrequest["location"] as AnyObject).latitude, longitude: (drinkrequest["location"] as AnyObject).longitude))
                            }
                        }
                    }
                    self.tableView.reloadData()
                } else {
                    print("No results")
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return requestUsernames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customers", for: indexPath)
        
        let driverCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let customerCLLocation = CLLocation(latitude: requestLocations[indexPath.row].latitude, longitude: requestLocations[indexPath.row].longitude)
        
        let distance = driverCLLocation.distance(from: customerCLLocation) / 1000
        let roundedDistance = round(distance * 100) / 100
        let convertDistance = roundedDistance * 0.62137
        let roundNewDistance = round(convertDistance * 100) / 100

        cell.textLabel?.text = requestUsernames[indexPath.row] + " - \(roundNewDistance)miles away"

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
