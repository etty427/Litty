//
//  CustomerLocationViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Ty rainey on 7/22/18.
//  Copyright © 2018 Parse. All rights reserved.
//

import UIKit
import MapKit
import Parse

final class CustomerLocationViewController: UIViewController {
    
    @IBOutlet weak var customerMapView: MKMapView!
    @IBOutlet weak var acceptButton: UIButton!
    
    var requestLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var requestUsername = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        customerMapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = requestLocation
        annotation.title = requestUsername
        customerMapView.addAnnotation(annotation)
    }

    
    @IBAction func acceptButtonPressed(_ sender: Any) {
        let query = PFQuery(className: "DrinkRequesters")
        query.whereKey("username", equalTo: requestUsername)
        query.findObjectsInBackground { (objects, error) in
            if let drinkRequests = objects {
                for drinkers in drinkRequests {
                    drinkers["driverResponded"] = PFUser.current()?.username
                    drinkers.saveInBackground()
                    let requestCLLocation = CLLocation(latitude: self.requestLocation.latitude, longitude: self.requestLocation.longitude)
                    CLGeocoder().reverseGeocodeLocation(requestCLLocation, completionHandler: { (placemarks, error) in
                        if let placemarks = placemarks {
                            if placemarks.count > 0 {
                                let mkPlacemark = MKPlacemark(placemark: placemarks[0])
                                let mapItem = MKMapItem(placemark: mkPlacemark)
                                mapItem.name = self.requestUsername
                                let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                                mapItem.openInMaps(launchOptions: launchOptions)
                            }
                        }
                    })
                }
            }
            else {
                self.acceptButton.setTitle("Request Job", for: [])
            }
        }
        
    }
    

}
