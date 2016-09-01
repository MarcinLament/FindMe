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

class ProfileViewController: UIViewController{
    
    @IBOutlet weak var userDisplayNameView: UITextView!
    
    @IBOutlet weak var profileImageView: AvatarImageView!
    
    override func viewDidLoad() {
        
        let userProfile = PFUser.currentUser()!["userProfile"] as! PFObject
        
        userProfile.fetchIfNeededInBackgroundWithBlock {
            (userProfile: PFObject?, error: NSError?) -> Void in
            
            let userName = userProfile!["displayName"] as! String
            
            self.userDisplayNameView.text = "Hello, " + userName
            
            AvatarGenerator.getAvatar(userName, imageView: self.profileImageView)
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

