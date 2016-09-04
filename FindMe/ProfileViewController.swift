//
//  ProfileViewController.swift
//  FindMe
//
//  Created by Marcin Lament on 07/08/2016.
//  Copyright © 2016 Marcin Lament. All rights reserved.
//

import Foundation
import UIKit
import Parse
import AvatarImageView
import CoreData

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var userDisplayNameView: UITextView!
    
    @IBOutlet weak var profileImageView: AvatarImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    var fetchedLocations: [ Location ]?
    let dateFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        
        downloadUserProfile()
    }
    
    func downloadUserProfile(){
        let userProfile = PFUser.currentUser()!["userProfile"] as! PFObject
        
        activityView.startAnimating()
        userProfile.fetchIfNeededInBackgroundWithBlock {
            (userProfile: PFObject?, error: NSError?) -> Void in
            
            self.activityView.stopAnimating()
            self.userDisplayNameView.hidden = false
            self.profileImageView.hidden = false
            
            let userName = userProfile!["displayName"] as! String
            
            self.userDisplayNameView.text = "Hello, " + userName
            
            AvatarGenerator.getAvatar(userName, imageView: self.profileImageView)
            
            let userId = PFUser.currentUser()!.objectId!
            
            Location.fetchAllLocations(userId, completionHandler: { (fetchError, fetchedLocations) in
                if fetchError != nil{
                    self.showAlert("Error", message: "Error fetching data from local storage", completion: nil)
                }else{
                    self.fetchedLocations = fetchedLocations
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(fetchedLocations == nil){ return 0 }
        return (fetchedLocations?.count)!
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let headerView = UILabel(frame: CGRectMake(0, 0, tableView.bounds.size.width, 30))
        
        if(fetchedLocations == nil || fetchedLocations?.count == 0){
            headerView.backgroundColor = UIColor.customPinkColor()
        }else{
            headerView.backgroundColor = UIColor.customPinkDarkColor()
            headerView.textColor = UIColor.whiteColor()
            headerView.text = " My shared locations"
        }
        
        return headerView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("TableCell") as UITableViewCell!
        if (cell != nil){
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle,
                                   reuseIdentifier: "TableCell")
        }
        
        let location = fetchedLocations![indexPath.row]
        
        cell!.backgroundColor = UIColor.customPinkColor()
        cell!.textLabel?.textColor = UIColor.whiteColor()
        cell!.detailTextLabel?.textColor = UIColor.whiteColor()
        
        let dateString = dateFormatter.stringFromDate(location.date!)
        
        cell!.textLabel!.text = timeAgoSinceDate(location.date!, numericDates: true) + ", " + dateString
        cell!.detailTextLabel!.text = "Latitude: \(location.latitude!), Longitude: \(location.longitude!)"
        
        return cell!
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let location = fetchedLocations![indexPath.item]
            CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(location)
            CoreDataStackManager.sharedInstance().saveContext()
            fetchedLocations!.removeAtIndex(indexPath.item)
            tableView.reloadData()
        }
    }
    
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil);
    }
    
    @IBAction func signOut(sender: AnyObject) {
        PFUser.logOut()
        performSegueWithIdentifier("ShowLoginViewControllerSegue", sender: nil)
    }
}

