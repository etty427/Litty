//
//  CustomerViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Ty rainey on 7/22/18.
//  Copyright © 2018 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit

final class CustomerViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    
    
    
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var customerActive = false
    var driverOnTheWay = false
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logout" {
            PFUser.logOut()
            locationManager.stopUpdatingLocation()
        }
         if segue.identifier == "shops" {
                performSegue(withIdentifier: "shops", sender: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        requestButton.isHidden = true
        getDrinksDelivered()
        let query = PFQuery(className: "DrinkRequesters")
        query.whereKey("username", equalTo: PFUser.current()?.username!)
        query.findObjectsInBackground { (objects, error) in
            if let objects = objects{
                if objects.count > 1 {
                self.customerActive = true
                self.requestButton.setTitle("Cancel Drinks", for: [])
                }
            }
            self.requestButton.isHidden = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location?.coordinate {
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            if driverOnTheWay == false {
                let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                self.mapView.setRegion(region, animated: true)
                self.mapView.removeAnnotations(mapView
                .annotations)
                let annotation = MKPointAnnotation()
                annotation.coordinate = userLocation
                annotation.title = "Your location"
                self.mapView.addAnnotation(annotation)
            }
            let query = PFQuery(className: "DrinkRequesters")
            query.whereKey("username", equalTo: PFUser.current()?.username!)
            query.findObjectsInBackground { (objects, error) in
                if let drinkRequests = objects {
                    for drinkRequest in drinkRequests {
                        drinkRequest["location"] = PFGeoPoint(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                        drinkRequest.saveInBackground()
                    }
                }
            }
        
        }
    
        if customerActive == true {
            let query = PFQuery(className: "DrinkRequesters")
            query.whereKey("username", equalTo: PFUser.current()?.username)
            query.findObjectsInBackground { (objects, error) in
                if let drinkRequests = objects {
                    for drinks in drinkRequests {
                        if let driverUsername = drinks["driverResponded"] {
                            let query = PFQuery(className: "DriverLocation")
                            query.whereKey("username", equalTo: driverUsername)
                            query.findObjectsInBackground(block: { (objects, error) in
                                if let driverLocations = objects {
                                    for driverLocationObject in driverLocations {
                                        if let driverLocation = driverLocationObject["location"] as? PFGeoPoint {
                                            self.driverOnTheWay = true
                                            let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                                            let customerCLLocation = CLLocation(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                                            let distance = customerCLLocation.distance(from: driverCLLocation) / 1000
                                            let roundedDistance = round(distance * 100) / 100
                                            let milesConverted = roundedDistance * 0.62137
                                            let newDistance = round(milesConverted * 100) / 100
                                            self.requestButton.setTitle("Your driver is \(newDistance) miles away", for: [])
                                            let latDelta = abs(driverLocation.latitude - self.userLocation.latitude) * 2 + 0.005
                                            let lonDelta = abs(driverLocation.longitude - self.userLocation.longitude) * 2 + 0.005
                                            let region = MKCoordinateRegion(center: self.userLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
                                            self.mapView.removeAnnotations(self.mapView.annotations)
                                            self.mapView.setRegion(region, animated: true)
                                            let userLocationAnnotation = MKPointAnnotation()
                                            userLocationAnnotation.coordinate = self.userLocation
                                            userLocationAnnotation.title = "Your location"
                                            self.mapView.addAnnotation(userLocationAnnotation)
                                            
                                            let driverLocationAnnotation = MKPointAnnotation()
                                            driverLocationAnnotation.coordinate = CLLocationCoordinate2D(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                                            driverLocationAnnotation.title = "Your driver"
                                            self.mapView.addAnnotation(driverLocationAnnotation)
                                        }
                                    }
                                }
                            })
                            
                        }
                    }
                }
            }
        }
    }
    func displayAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func requestButtonPressed(_ sender: Any) {
        getDrinksDelivered()
    }
    
    func getDrinksDelivered() {
        if customerActive {
            customerActive = false
            requestButton.setTitle("Request Drinks", for: [])
            let query = PFQuery(className: "DrinkRequesters")
            query.whereKey("username", equalTo: PFUser.current()?.username!)
            query.findObjectsInBackground { (objects, error) in
                if let drinkRequests = objects {
                    for drinkRequest in drinkRequests {
                        drinkRequest.deleteInBackground()
                    }
                }
            }
        }
        else {
            if userLocation.longitude != 0 && userLocation.latitude != 0 {
                customerActive = true
                self.requestButton.setTitle("Cancel Order", for: [])
                let request = PFObject(className: "DrinkRequesters")
                request["username"] = PFUser.current()?.username
                request["location"] = PFGeoPoint(latitude: userLocation.latitude, longitude: userLocation.longitude)
                
                request.saveInBackground { (success, error) in
                    if success {
                        print("Request Drinks")
                        
                    }
                    else {
                        self.requestButton.setTitle("Request Drinks", for: [])
                        self.customerActive = false
                        self.displayAlert(title: "Could not request drinks", message: "Please try again")
                    }
                }
            }
            else {
                displayAlert(title: "Could not request drinks", message: "Unable to detect location")
            }
        }
    }
    
}
