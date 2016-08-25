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
    @IBOutlet weak var shareLocationButton: UIButton!
    @IBOutlet weak var shareLocationActivityView: UIActivityIndicatorView!
    
    var userCurrentLocation: CLLocation?
    var locationManager: CLLocationManager!

    var friendsList: [PFObject]?
    
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
        fetchFriendsLocation()
    }
    
    @IBAction func shareLocation(sender: AnyObject) {
        
        //check if user has granted location access
        let status = CLLocationManager.authorizationStatus()
        if(status == .NotDetermined || status == .Denied){
            showAlert("Requesting user location", message: "Allow access to your location to share it with your friends", positiveButtonText: "Settings", negativeButtonText: "Cancel", positiveCompletion: { (UIAlertAction) in
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                }, negativeCompletion: nil)
            
            return
        }else if(userCurrentLocation == nil){
            showAlert("Error", message: "Cannot retrieve current location. Please try again shortly.", completion: {(UIAlertAction) in
                //request user position
                self.locationManager.requestAlwaysAuthorization()
                self.locationManager.requestWhenInUseAuthorization()
            })
            return
        }
        
        //get friends list
        shareLocationActivityView.startAnimating()
        shareLocationButton.hidden = true
        
        let userProfile = PFUser.currentUser()!["userProfile"] as! PFObject
        userProfile.fetchIfNeededInBackgroundWithBlock {
            (userProfile: PFObject?, error: NSError?) -> Void in
            
            if(error != nil){
                print(error?.localizedDescription)
                self.shareLocationActivityView.stopAnimating()
                self.shareLocationButton.hidden = false
                return
            }
            
            let relation = userProfile!.relationForKey("friends")
            relation.query().findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                if let error = error {
                    print(error.localizedDescription)
                } else{
                    print(objects![0]["displayName"])
                    self.friendsList = objects
                    
                    self.performSegueWithIdentifier("OpenSelectFriendsSegue", sender: nil)
                }
                self.shareLocationActivityView.stopAnimating()
                self.shareLocationButton.hidden = false
            }
        }
        
        
        
        //        let params: [NSObject : NSObject] = ["latitude": 51.5074,
        //                                             "longitude":0.1278,
        //                                             "recipients":["dmPgREiRiY","8Hnnz3eAUH"]]
        //
        //        PFCloud.callFunctionInBackground("shareLocation", withParameters: params) {
        //            (response: AnyObject?, error: NSError?) -> Void in
        //
        //            if(error != nil){
        //                print(error)
        //            }
        //
        //            print(response)
        //        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if segue!.identifier == "OpenSelectFriendsSegue" {
            let viewController:SelectFriendsViewController = segue!.destinationViewController as! SelectFriendsViewController
            viewController.friendsList = friendsList
            
//            let indexPath = self.tableView.indexPathForSelectedRow()
//            viewController.pinCode = self.exams[indexPath.row]
            
        }
    }
    
    func fetchFriendsLocation(){
        self.friendInfoActivityView.startAnimating()
        PFCloud.callFunctionInBackground("getFriendsLocations", withParameters: nil) {
            (response: AnyObject?, error: NSError?) -> Void in
            
            self.friendInfoActivityView.stopAnimating()
            
            if(error != nil){
                print(error)
                return;
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
        userCurrentLocation = locations.last
        
        let center = CLLocationCoordinate2D(latitude: userCurrentLocation!.coordinate.latitude, longitude: userCurrentLocation!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
    }
}