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
import CoreData

class MapViewController: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var friendInfoActivityView: UIActivityIndicatorView!
    @IBOutlet weak var shareLocationButton: UIButton!
    @IBOutlet weak var shareLocationActivityView: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!
    
    var userCurrentLocation: CLLocation?
    var locationManager: CLLocationManager!
    var fetchedLocation: Location?
    var hasSetInitialLocation: Bool = false
    var friendsList: [PFObject]?
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    override func viewDidLoad() {
        
        if(CLLocationManager.locationServicesEnabled()){

            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            let status = CLLocationManager.authorizationStatus()
            if status == .NotDetermined || status == .Denied || status == .AuthorizedWhenInUse {
                locationManager.requestAlwaysAuthorization()
                locationManager.requestWhenInUseAuthorization()
            }
            
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
        
        stylePrimaryButton(shareLocationButton, roundedCorners: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        downloadFriendsLocation()
        fetchUserLatestLocationFromLocalStorage()
    }
    
    func fetchUserLatestLocationFromLocalStorage(){
        shareLocationActivityView.startAnimating()
        shareLocationButton.hidden = true
        
        let userId = PFUser.currentUser()!.objectId!
        Location.fetchLatestLocation(userId, completionHandler: { (fetchError, fetchedLocation) in
            self.shareLocationActivityView.stopAnimating()
            self.shareLocationButton.hidden = false
            
            if fetchError != nil{
                self.showAlert("Error", message: "Error fetching data from local storage", completion: nil)
            }else{
                self.fetchedLocation = fetchedLocation
                self.updateShareButtonText()
            }
        })
    }
    
    @IBAction func shareLocation(sender: AnyObject) {
        
        let status = CLLocationManager.authorizationStatus()
        if(status == .NotDetermined || status == .Denied){
            showAlert("Requesting user location", message: "Allow access to your location to share it with your friends", positiveButtonText: "Settings", negativeButtonText: "Cancel", positiveCompletion: { (UIAlertAction) in
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                }, negativeCompletion: nil)
            
            return
        }else if(userCurrentLocation == nil){
            showAlert("Error", message: "Cannot retrieve current location. Please try again shortly.", completion: {(UIAlertAction) in
                self.locationManager.requestAlwaysAuthorization()
                self.locationManager.requestWhenInUseAuthorization()
            })
            return
        }
        
        downloadFriendsListForCurrentUser()
    }
    
    func downloadFriendsListForCurrentUser(){
        shareLocationActivityView.startAnimating()
        shareLocationButton.hidden = true
        
        let userProfile = PFUser.currentUser()!["userProfile"] as! PFObject
        userProfile.fetchIfNeededInBackgroundWithBlock {
            (userProfile: PFObject?, error: NSError?) -> Void in
            
            if(error != nil){
                self.shareLocationActivityView.stopAnimating()
                self.shareLocationButton.hidden = false
                self.showAlert("Error", message: (error?.localizedDescription)!, completion: nil)
                return
            }
            
            let relation = userProfile!.relationForKey("friends")
            relation.query().findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
                
                self.shareLocationActivityView.stopAnimating()
                self.shareLocationButton.hidden = false
                
                if (error == nil){
                    
                    if(objects?.count == 0){
                        self.showAlert("Cannot share location", message: "You friends list is empty. You can add new friends from the Friends section.", completion: nil)
                        return;
                    }
                    
                    self.friendsList = objects
                    self.performSegueWithIdentifier("OpenSelectFriendsSegue", sender: nil)
                }
            }
        }
    }
    
    func downloadFriendsLocation(){
        self.friendInfoActivityView.startAnimating()
        statusLabel.hidden = true
        PFCloud.callFunctionInBackground("getFriendsLocations", withParameters: nil) {
            (response: AnyObject?, error: NSError?) -> Void in
            
            self.friendInfoActivityView.stopAnimating()
            self.statusLabel.hidden = false
            
            if(error != nil){
                self.showAlert("Error", message: (error?.localizedDescription)!, completion: nil)
                self.updateFriendsLocationButtonText(nil)
            }else{
                
                var friendLocationData: FriendLocationData?
                if let data = response!.dataUsingEncoding(NSUTF8StringEncoding) {
                    do {
                        let rootObject = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
                        friendLocationData = FriendLocationData(jsonObject: rootObject!)
                    } catch{}
                }
                
                self.updateFriendsLocationButtonText(friendLocationData)
                self.showFriendsOnMap((friendLocationData?.friendLocationList)!)
            }
        }
    }
    
    func updateShareButtonText(){
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Center
        
        var text1Attributes = [String : NSObject]()
        text1Attributes[NSFontAttributeName] = UIFont(name: "Helvetica Neue", size: 24.0)!
        text1Attributes[NSForegroundColorAttributeName] = UIColor.whiteColor()
        text1Attributes[NSParagraphStyleAttributeName] = paragraphStyle
        let text1 = NSMutableAttributedString(string: "Share location", attributes: text1Attributes)
        
        if(fetchedLocation != nil){
            shareLocationButton.titleLabel?.numberOfLines = 2
            var text2Attributes = [String : NSObject]()
            text2Attributes[NSFontAttributeName] = UIFont(name: "Helvetica Neue", size: 14.0)!
            text2Attributes[NSForegroundColorAttributeName] = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.8)
            text2Attributes[NSParagraphStyleAttributeName] = paragraphStyle
            let text2 = NSAttributedString(string: "\n last shared " + timeAgoSinceDate(fetchedLocation!.date!, numericDates: true), attributes: text2Attributes)
            text1.appendAttributedString(text2)
        }
        
        shareLocationButton.setAttributedTitle(text1, forState: .Normal)
    }
    
    func updateFriendsLocationButtonText(friendLocationData: FriendLocationData?){
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Center
        
        if(friendLocationData != nil && friendLocationData?.friendLocationList.count > 0){
            
            let count = friendLocationData?.friendLocationList.count
            
            var text1Attributes = [String : NSObject]()
            text1Attributes[NSFontAttributeName] = UIFont(name: "Helvetica Neue", size: 24.0)!
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
            annotations.append(annotation)
        }
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)
        
        mapView.layoutMargins = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
        mapView.showAnnotations(mapView.annotations, animated: true)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if segue!.identifier == "OpenSelectFriendsSegue" {
            let viewController:SelectFriendsViewController = segue!.destinationViewController as! SelectFriendsViewController
            viewController.friendsList = friendsList
            viewController.userCurrentLocation = userCurrentLocation
        }
    }
}