//
//  ViewController.swift
//  FindMe
//
//  Created by Marcin Lament on 06/08/2016.
//  Copyright © 2016 Marcin Lament. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var usernameView: UIInputTextView!
    @IBOutlet weak var passwordView: UIInputTextView!
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        stylePrimaryButton(loginButton, roundedCorners: true)
        stylePrimaryBackground()
        
        usernameView.setStyle("Username", textPlaceholder: "Username", isPassword: false)
        passwordView.setStyle("Password", textPlaceholder: "Password", isPassword: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() != nil {
            print("User logged in, moving on...")
            openMapViewController()
            return
        }
        print("User not logged in")
        
        
        
        usernameView.hidden = false
        passwordView.hidden = false
        loginButton.hidden = false
        registerButton.hidden = false
        logoView.hidden = false
    }

    @IBAction func login(sender: AnyObject) {
        
        if(usernameView.getText() == "" || passwordView.getText() == ""){
            showAlert("Invalid details", message: "Enter your Username and Password", completion: nil)
            return
        }
        activityView.startAnimating()
        PFUser.logInWithUsernameInBackground(usernameView.getText(), password: passwordView.getText()) { (user, error) -> Void in
            self.activityView.stopAnimating()
            
            if error == nil {
                self.openMapViewController()
            } else {
                self.showAlert("Error", message: error!.localizedDescription, completion: nil)
            }
        }
        
    }

    @IBAction func register(sender: AnyObject) {

        let next = storyboard?.instantiateViewControllerWithIdentifier("RegisterViewController")
        self.presentViewController(next!, animated: true, completion: nil)
    }
    
    func openMapViewController(){
        performSegueWithIdentifier("OpenUserAreaSegue", sender: nil)
    }
    
    
}

