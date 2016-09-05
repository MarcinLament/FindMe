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
    
    @IBOutlet weak var emailView: UIInputTextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    var userData: UserData?
    
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        initStyles()
        downloadUserFriendList()
    }
    
    func initStyles(){
        stylePrimaryButton(inviteButton, roundedCorners: true)
        emailView.setStyle("Email", textPlaceholder: "Email address", isPassword: false)
    }
    
    func downloadUserFriendList(){
        PFCloud.callFunctionInBackground("getFriends", withParameters: nil) {
            (response: AnyObject?, error: NSError?) -> Void in
            
            if(error == nil){
                if let data = response!.dataUsingEncoding(NSUTF8StringEncoding) {
                    do {
                        let rootObject = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
                        self.userData = UserData(jsonObject: rootObject!)
                        self.tableView.reloadData()
                    } catch{}
                }
            }
        }
    }
    
    func acceptFriendRequest(friendRequest: FriendRequest){

        let params: [NSObject : NSObject] = ["authorProfileId":friendRequest.authorProfileId!,
                                            "friendRequestId":friendRequest.objectId!]
        PFCloud.callFunctionInBackground("acceptFriendRequest", withParameters: params) {
            (response: AnyObject?, error: NSError?) -> Void in
            
            if(error != nil){
                self.showAlert("Error", message: (error?.localizedDescription)!, completion: nil)
            }else{
                self.downloadUserFriendList()
            }
        }
    }
    
    func declineFriendRequest(friendRequest: FriendRequest){
        let params: [NSObject : NSObject] = ["friendRequestId":friendRequest.objectId!]
        PFCloud.callFunctionInBackground("declineFriendRequest", withParameters: params) {
            (response: AnyObject?, error: NSError?) -> Void in
            
            if(error != nil){
                self.showAlert("Error", message: (error?.localizedDescription)!, completion: nil)
            }else{
                self.downloadUserFriendList()
            }
        }
    }
    
    func sendFriendRequest(){
        
        activityView.startAnimating()
        let params: [NSObject : NSObject] = ["recipientEmail":emailView.getText()]
        
        PFCloud.callFunctionInBackground("sendFriendRequest", withParameters: params) {
            (response: AnyObject?, error: NSError?) -> Void in
            
            self.activityView.stopAnimating()
            if(error != nil){
                self.showAlert("Error", message: (error?.localizedDescription)!, completion: nil)
            }else{
                self.emailView.textField?.text = ""
            }
            
            self.downloadUserFriendList()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        
        var title: String?
        switch section {
        case 0:
            if(userData?.friendRequestList.count == 0){
                title = "Awaiting your action"
            }
            break;
        case 1:
            if(userData?.sentInvitesList.count == 0){
                title = "Sent requests"
            }
            break;
        case 2:
            if(userData?.friendsList.count == 0){
                title = "Friends"
            }
            break;
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
            let authorName = userData?.friendRequestList[indexPath.row].authorName
            cell!.textLabel!.text = authorName
            cell!.detailTextLabel!.text = "Accept friend request from \(authorName!)"
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
        
        sendFriendRequest()
    }
}