//
//  FriendListViewController.swift
//  FindMe
//
//  Created by Marcin Lament on 08/08/2016.
//  Copyright © 2016 Marcin Lament. All rights reserved.
//

import Foundation
import UIKit
import Parse


class FriendListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
//    var friends: [PFObject]?
//    var friendRequests: [PFObject]?
//    
    var userData: UserData?
    
    @IBOutlet weak var emailView: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
    
        PFCloud.callFunctionInBackground("getFriends", withParameters: nil) {
            (response: AnyObject?, error: NSError?) -> Void in
            print(response)

            if(error != nil){
                print("ERRORR!!!!")
            }else{
                if let data = response!.dataUsingEncoding(NSUTF8StringEncoding) {
                    do {
                        let rootObject = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
                        self.userData = UserData(jsonObject: rootObject!)
                        print(self.userData?.friendsList.count)
                    } catch let error as NSError {
                        print("\n")
                        print(error)
                    }
                }
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

//        var sections = 0;
//        sections += (userData != nil && userData!.friendRequestList.count > 0) ? 1 : 0
//        sections += (userData != nil && userData?.friendsList.count > 0) ? 1 : 0
        return 3
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(userData == nil){ return 0 }
        
        switch section {
        case 0:
            return (userData?.friendRequestList.count)!
        case 1:
            return (userData?.sentInvitesList.count)!
        case 2:
            return (userData?.friendsList.count)!
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Friend requests"
        case 1:
            return "Sent Invites"
        case 2:
            return "Friends"
        default:
            return ""
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("TableCell") as UITableViewCell!
        if (cell != nil){
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle,
                                   reuseIdentifier: "TableCell")
        }
        
        switch indexPath.section {
        case 0:
            cell!.textLabel!.text = userData?.friendRequestList[indexPath.row].authorName
            cell!.detailTextLabel!.text = "Click here to accept or decline"
            break;
        case 1:
            cell!.textLabel!.text = userData?.sentInvitesList[indexPath.row].recipientEmail
            cell!.detailTextLabel!.text = "Status: \(userData?.sentInvitesList[indexPath.row].status)"
            break;
        case 2:
            cell!.textLabel!.text = userData?.friendsList[indexPath.row].displayName
            break;
        default:
            break;
        }
        
        return cell!
    }
    
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func invite(sender: AnyObject) {
    }
}