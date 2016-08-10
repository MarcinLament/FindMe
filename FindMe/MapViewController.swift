//
//  MapViewController.swift
//  FindMe
//
//  Created by Marcin Lament on 06/08/2016.
//  Copyright © 2016 Marcin Lament. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Parse

class MapViewController: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var friendInfoTitleView: UILabel!
    @IBOutlet weak var friendInfoSummaryView: UILabel!
    @IBOutlet weak var friendInfoActivityView: UIActivityIndicatorView!
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        
        if(CLLocationManager.locationServicesEnabled()){
            print("enabled")
            
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            let status = CLLocationManager.authorizationStatus()
            if status == .NotDetermined || status == .Denied || status == .AuthorizedWhenInUse {
                // present an alert indicating location authorization required
                // and offer to take the user to Settings for the app via
                // UIApplication -openUrl: and UIApplicationOpenSettingsURLString
                locationManager.requestAlwaysAuthorization()
                locationManager.requestWhenInUseAuthorization()
            }
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }else{
            print("disabled")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        fetchFriendsLocation();
    }
    
    @IBAction func shareLocation(sender: AnyObject) {
        //51.5074° N, 0.1278° W
        let params: [NSObject : NSObject] = ["latitude": 51.5074,
                                             "longitude":0.1278,
                                             "recipients":["dmPgREiRiY","8Hnnz3eAUH"]]
        
        PFCloud.callFunctionInBackground("shareLocation", withParameters: params) {
            (response: AnyObject?, error: NSError?) -> Void in
            
            if(error != nil){
                print(error)
            }
            
            print(response)
        }
    }
    
    func fetchFriendsLocation(){
        self.friendInfoActivityView.startAnimating()
        PFCloud.callFunctionInBackground("getFriendsLocations", withParameters: nil) {
            (response: AnyObject?, error: NSError?) -> Void in
            
            self.friendInfoActivityView.stopAnimating()
            
            if(error != nil){
                print(error)
            }
            
            var friendLocationData: FriendLocationData?
            if let data = response!.dataUsingEncoding(NSUTF8StringEncoding) {
                do {
                    let rootObject = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
                    friendLocationData = FriendLocationData(jsonObject: rootObject!)
                } catch let error as NSError {
                    print("\n")
                    print(error)
                }
            }
            
            self.showFriendsLocations(friendLocationData)
        }
    }
    
    func showFriendsLocations(friendLocationData: FriendLocationData?){
        if(friendLocationData != nil && friendLocationData?.friendLocationList.count > 0){
            friendInfoTitleView.hidden = false
            friendInfoSummaryView.hidden = false
            
            let count = friendLocationData?.friendLocationList.count
            var text = String(count!) + " "
            text += (count == 1) ? "friend" : "friends"
            friendInfoTitleView.text = text
        }else{
            friendInfoSummaryView.hidden = false
            friendInfoSummaryView.text = "No friends on the map"
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if(status == .AuthorizedWhenInUse || status == .AuthorizedAlways){
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
    }
}