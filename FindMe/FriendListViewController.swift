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
    
    @IBOutlet weak var emailView: UIInputTextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        stylePrimaryButton(inviteButton, roundedCorners: true)
//        stylePrimaryBackground()
        emailView.setStyle("Email", textPlaceholder: "Email address", isPassword: false)
    
//        tableView.backgroundColor = UIColor(red:0.88, green:0.22, blue:0.44, alpha:1.0)
        
        getUserFriendList()
    }
    
    func getUserFriendList(){
        PFCloud.callFunctionInBackground("getFriends", withParameters: nil) {
            (response: AnyObject?, error: NSError?) -> Void in
            print(response)
            
            if(error != nil){
                print("ERRORR!!!!, " + (error?.localizedDescription)! as String)
            }else{
                if let data = response!.dataUsingEncoding(NSUTF8StringEncoding) {
                    do {
                        let rootObject = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
                        self.userData = UserData(jsonObject: rootObject!)
                        print(self.userData?.friendsList.count)
                        self.tableView.reloadData()
                    } catch let error as NSError {
                        print("\n")
                        print(error)
                    }
                }
            }
        }
    }
    
    func acceptFriendRequest(friendRequest: FriendRequest){
        print("acceptReq: \(friendRequest.authorProfileId)")
        
        let params: [NSObject : NSObject] = ["authorProfileId":friendRequest.authorProfileId!,
                                            "friendRequestId":friendRequest.objectId!]
        PFCloud.callFunctionInBackground("acceptFriendRequest", withParameters: params) {
            (response: AnyObject?, error: NSError?) -> Void in
            
            if(error != nil){
                print(error)
            }
            
            self.getUserFriendList()
        }
    }
    
    func declineFriendRequest(friendRequest: FriendRequest){
        let params: [NSObject : NSObject] = ["friendRequestId":friendRequest.objectId!]
        PFCloud.callFunctionInBackground("declineFriendRequest", withParameters: params) {
            (response: AnyObject?, error: NSError?) -> Void in
            
            if(error != nil){
                print(error)
            }
            
            self.getUserFriendList()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        
        
        let title: String?
        switch section {
        case 0:
            title = userData?.friendRequestList.count == 0 ? nil : "Sent requests"
        case 1:
            title = userData?.sentInvitesList.count == 0 ? nil : "Awaiting your action"
        case 2:
            title = userData?.friendsList.count == 0 ? nil : "Friends"
        default:
            return nil
        }
        
        let headerView = UILabel(frame: CGRectMake(0, 0, tableView.bounds.size.width, 30))
        
        if(title == nil){
            headerView.backgroundColor = UIColor.customPinkColor()
        }else{
            headerView.backgroundColor = UIColor.customPinkDarkColor()
            headerView.textColor = UIColor.whiteColor()
            headerView.text = " " + title!
        }
        
        return headerView
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section == 0){
            print("Selected \(indexPath.row)")
            
            showAlert("Friend request", message: "\(userData!.friendRequestList[indexPath.row].authorName!) sent you friend request", positiveButtonText: "Accept", negativeButtonText: "Decline", positiveCompletion: { (UIAlertAction) in
                self.acceptFriendRequest(self.userData!.friendRequestList[indexPath.row])
                }, negativeCompletion: { (UIAlertAction) in
                    self.declineFriendRequest(self.userData!.friendRequestList[indexPath.row])
            })
        }
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
            return userData?.friendRequestList.count == 0 ? nil : "Friend requests"
        case 1:
            return userData?.sentInvitesList.count == 0 ? nil : "Avaiting response"
        case 2:
            return userData?.friendsList.count == 0 ? nil : "Friends"
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
        
        cell!.backgroundColor = UIColor.customPinkColor()
        cell!.textLabel?.textColor = UIColor.whiteColor()
        cell!.detailTextLabel?.textColor = UIColor.whiteColor()
        
        switch indexPath.section {
        case 0:
            cell!.textLabel!.text = userData?.friendRequestList[indexPath.row].authorName
            cell!.detailTextLabel!.text = "Click here to accept or decline"
            cell!.userInteractionEnabled = true
            break;
        case 1:
            cell!.textLabel!.text = userData!.sentInvitesList[indexPath.row].recipientEmail! as String
            cell!.userInteractionEnabled = false
            break;
        case 2:
            cell!.textLabel!.text = userData?.friendsList[indexPath.row].displayName
            cell!.userInteractionEnabled = false
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
        
        if(!isValidEmail(emailView.getText())){
            showAlert("Error", message: "Invalid email address", completion: nil)
            return;
        }
        
        activityView.startAnimating()
        let params: [NSObject : NSObject] = ["recipientEmail":emailView.getText()]
        PFCloud.callFunctionInBackground("sendFriendRequest", withParameters: params) {
            (response: AnyObject?, error: NSError?) -> Void in
            
            self.activityView.stopAnimating()
            if(error != nil){
                print(error)
            }else{
                self.emailView.textField?.text = ""
            }
            
            self.getUserFriendList()
        }
    }
}