//
//  FriendsViewController.swift
//  FindMe
//
//  Created by Marcin Lament on 07/08/2016.
//  Copyright © 2016 Marcin Lament. All rights reserved.
//

import Foundation
import UIKit
import Parse

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var friends: [PFObject]?
    var friendRequests: [PFObject]?
    
    @IBOutlet weak var emailView: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        tableView.delegate = self
        
        let user = PFUser.currentUser()
        let friendsRelation = user!.relationForKey("Friends")
        let friendRequestRelation = user!.relationForKey("FriendRequest")
        
        friendsRelation.query().findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            self.friends = objects
            self.tableView.reloadData()
        }
        
        friendRequestRelation.query().findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            self.friendRequests = objects
            self.tableView.reloadData()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        var sections = 0;
        sections += (friendRequests != nil && friendRequests?.count > 0) ? 1 : 0
        sections += (friends != nil && friends?.count > 0) ? 1 : 0
        return sections
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(friendRequests != nil && friendRequests?.count > 0 && section == 0){
            return (friendRequests?.count)!
        }
        
        if(friends != nil && friends?.count > 0 && section == 0){
            return (friends?.count)!
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("TableCell") as UITableViewCell!
        if (cell != nil){
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle,
                                   reuseIdentifier: "TableCell")
        }
        cell!.detailTextLabel!.text = "some text"
        
        return cell!
    }
    
    
    @IBAction func invite(sender: AnyObject) {
    }
}