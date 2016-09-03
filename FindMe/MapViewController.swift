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
    @IBOutlet weak var friendInfoActivityView: UIActivityIndicatorView!
    @IBOutlet weak var shareLocationButton: UIButton!
    @IBOutlet weak var shareLocationActivityView: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!
    
    var userCurrentLocation: CLLocation?
    var locationManager: CLLocationManager!
    
    var hasSetInitialLocation: Bool = false

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
        
        stylePrimaryButton(shareLocationButton, roundedCorners: false)
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
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if segue!.identifier == "OpenSelectFriendsSegue" {
            let viewController:SelectFriendsViewController = segue!.destinationViewController as! SelectFriendsViewController
            viewController.friendsList = friendsList
            viewController.userCurrentLocation = userCurrentLocation
            
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
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
            
            print(response)
            
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
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Center
        
        if(friendLocationData != nil && friendLocationData?.friendLocationList.count > 0){
            
            let count = friendLocationData?.friendLocationList.count
            
            var text1Attributes = [String : NSObject]()
            text1Attributes[NSFontAttributeName] = UIFont(name: "Helvetica Neue", size: 26.0)!
            text1Attributes[NSForegroundColorAttributeName] = UIColor.whiteColor()
            text1Attributes[NSParagraphStyleAttributeName] = paragraphStyle
            let text1 = NSMutableAttributedString(string: "\(count!) \((count! == 1) ? "friend" : "friends")", attributes: text1Attributes)
            
            var text2Attributes = [String : NSObject]()
            text2Attributes[NSFontAttributeName] = UIFont(name: "Helvetica Neue", size: 14.0)!
            text2Attributes[NSForegroundColorAttributeName] = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.8)
            text2Attributes[NSParagraphStyleAttributeName] = paragraphStyle
            let text2 = NSAttributedString(string: "\n currently on the map", attributes: text2Attributes)
            text1.appendAttributedString(text2)
            
            statusLabel.attributedText = text1
            
            //show on the map
            showFriendsOnMap((friendLocationData?.friendLocationList)!)
            
        }else{
            
            var text1Attributes = [String : NSObject]()
            text1Attributes[NSFontAttributeName] = UIFont(name: "Helvetica Neue", size: 16.0)!
            text1Attributes[NSForegroundColorAttributeName] = UIColor.whiteColor()
            text1Attributes[NSParagraphStyleAttributeName] = paragraphStyle
            let text1 = NSMutableAttributedString(string: "No friends on the map", attributes: text1Attributes)
            statusLabel.attributedText = text1
        }
    }
    
    func showFriendsOnMap(friendLocationList: [UserProfile]){
        
        var annotations = [MKPointAnnotation]()
        for friendLocation in friendLocationList {
            let coordinate = CLLocationCoordinate2D(latitude: (friendLocation.userLocation?.latitude)!, longitude: (friendLocation.userLocation?.longitude)!)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = friendLocation.displayName
            annotation.subtitle = "Shared \(getFormettedDate((friendLocation.userLocation?.date)!))"
            
//            if(checkin.isUsersPost){
//                let span:MKCoordinateSpan = MKCoordinateSpanMake(0.5, 0.5)
//                let region: MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
//                mapView.setRegion(region, animated: true)
//            }
            
            annotations.append(annotation)
        }
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)
        
        mapView.layoutMargins = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
        mapView.showAnnotations(mapView.annotations, animated: true)
        
//
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if(status == .AuthorizedWhenInUse || status == .AuthorizedAlways){
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
    }
    
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        userCurrentLocation = locations.last
        if hasSetInitialLocation {
            return;
        }else{
            hasSetInitialLocation = true
        }
        
        let center = CLLocationCoordinate2D(latitude: userCurrentLocation!.coordinate.latitude, longitude: userCurrentLocation!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
    }
    
    func getFormettedDate(dateString: String) -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        
        let date = dateFormatter.dateFromString(dateString)
        if(date != nil){
            return timeAgoSinceDate(date!, numericDates: true)
        }
        
        return ""
    }
}