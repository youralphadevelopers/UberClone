//
//  DriverViewController.swift
//  Parse1.17.3_Bolts1.9_iOS13_WithoutPods
//
//  Created by AlphaCoders on 23/11/20.
//  Copyright © 2020 Back4app. All rights reserved.
//

import UIKit
import MapKit
import Parse

class DriverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    
    var requestUsernames = [String]()
    var requestLocations = [CLLocationCoordinate2D]()
    
    @IBOutlet weak var tableview: UITableView!
    
    var userLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "acceptRequest" {
            
            if let destination = segue.destination as? RiderLocationViewController {
                
                if let row = tableview.indexPathForSelectedRow?.row {
                    
                    destination.requestLocation = requestLocations[row]
                    
                    destination.requestUsername = requestUsernames[row]
                }
            }
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return requestUsernames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableview.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let driverCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        
        let riderCLLocation = CLLocation(latitude: requestLocations[indexPath.row].latitude, longitude: requestLocations[indexPath.row].longitude)
        
        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
        
        let roundedDistance = round(distance * 100) / 100

        cell.textLabel?.text = requestUsernames[indexPath.row] + " - \(roundedDistance)km away"

        return cell
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = manager.location?.coordinate {
            
            userLocation = location
            
            let driverLocationQuery = PFQuery(className: "DriverLocation")
            
            driverLocationQuery.whereKey("username", equalTo: (PFUser.current()?.username)!)
            
            driverLocationQuery.findObjectsInBackground(block: { ( objects, error ) in
                
                if let driverLocations = objects{
                    
                    for driverLocation in driverLocations{
                        
                        driverLocation["location"] = PFGeoPoint(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                        
                        driverLocation.deleteInBackground()
                    }
                }
                
                let driverLocation = PFObject(className: "DriverLocation")
                
                driverLocation["username"] = PFUser.current()?.username
                
                driverLocation["location"] = PFGeoPoint(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                
                driverLocation.saveInBackground()
            })
            
            let query = PFQuery(className: "RiderRequest")
            
            query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: location.latitude, longitude: location.longitude))
            
            query.limit = 10
            
            query.findObjectsInBackground(block:{ ( objects, error ) in
                
                if let riderRequests = objects{
                    
                    self.requestUsernames.removeAll()
                    self.requestLocations.removeAll()
                    
                    for riderRequest in riderRequests {
                        
                        if let username = riderRequest["username"] as? String{
                            
                            if riderRequest["driverResponded"] == nil {
                                
                                self.requestUsernames.append(username)
                                
                                self.requestLocations.append(CLLocationCoordinate2D(latitude: (riderRequest["location"] as AnyObject).latitude , longitude:(riderRequest["location"] as AnyObject).longitude))
                            }
                        }
                    }
                    self.tableview.reloadData()
                }
            })
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
