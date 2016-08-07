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
class ProfileViewController: UIViewController{
    
    @IBOutlet weak var userDisplayNameView: UITextView!
    
    override func viewDidLoad() {
        
        let userProfile = PFUser.currentUser()!["user_profile"] as! PFObject
        
        userProfile.fetchIfNeededInBackgroundWithBlock {
            (userProfile: PFObject?, error: NSError?) -> Void in
            self.userDisplayNameView.text = "Hello, " + (userProfile!["display_name"] as! String)
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