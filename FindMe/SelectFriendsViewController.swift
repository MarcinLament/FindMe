//
//  SelectFriendsViewController.swift
//  FindMe
//
//  Created by Marcin Lament on 25/08/2016.
//  Copyright © 2016 Marcin Lament. All rights reserved.
//

import Foundation
import UIKit
import Parse

class SelectFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    var friendsList: [PFObject]?
    var userCurrentLocation: CLLocation?
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    @IBAction func done(sender: AnyObject) {
        
        if(self.tableView.indexPathsForSelectedRows == nil){
            showAlert("Error", message: "You have to select at least one friend", completion: nil)
            return;
        }
        
        let rows = self.tableView.indexPathsForSelectedRows!.map{$0.row}
        
        var recipients = [String]()
        for row in rows {
            recipients.append(friendsList![row].objectId!)
        }

        let params: [NSObject : NSObject] = ["latitude": (userCurrentLocation?.coordinate.latitude)!,
                                             "longitude": (userCurrentLocation?.coordinate.longitude)!,
                                             "recipients":recipients]
        shareLocation(params)
    }
    
    func shareLocation(params: [NSObject : NSObject]){
        activityView.startAnimating()
        PFCloud.callFunctionInBackground("shareLocation", withParameters: params) {
            (response: AnyObject?, error: NSError?) -> Void in
            
            self.activityView.stopAnimating()
            if(error != nil){
                return
            }
            
            self.saveLocationToLocalStorage()
            
            self.showAlert("Great!", message: "You have shared your location successfully!", completion: { (UIAlertAction) in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }
    
    func saveLocationToLocalStorage(){
        _ = Location(
            userId: PFUser.currentUser()!.objectId!,
            date: NSDate(),
            latitude: (userCurrentLocation?.coordinate.latitude)!,
            longitude: (userCurrentLocation?.coordinate.longitude)!,
            context: CoreDataStackManager.sharedInstance().managedObjectContext
        )

        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(friendsList == nil) {return 0}
        else{ return (friendsList?.count)!}
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("TableCell") as UITableViewCell!
        let displayName = friendsList![indexPath.row]["displayName"] as! String
        cell!.textLabel!.text = displayName
        cell!.textLabel!.textColor = UIColor.whiteColor()
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.customPinkDarkColor()
    }

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cellToDeSelect:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        cellToDeSelect.contentView.backgroundColor = UIColor.customPinkColor()
    }
}