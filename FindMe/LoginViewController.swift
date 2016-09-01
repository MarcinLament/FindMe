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

    @IBOutlet weak var usernameView: UITextField!
    @IBOutlet weak var passwordView: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var tempImgView: UIImageView!
    
    
    override func viewDidLoad() {
        configureBackground()
        
        tempImgView.backgroundColor = UIColor.redColor()
        tempImgView.layer.cornerRadius = 8.0
        tempImgView.clipsToBounds = true
        tempImgView.image = UIImage(named:"Icon")
        tempImgView.layer.borderWidth = 10
    }
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() != nil {
            print("User logged in, moving on...")
            openMapViewController()
            return
        }
        print("User not logged in")
        
        usernameView.autocorrectionType = .No
        
        usernameView.hidden = false
        passwordView.hidden = false
        loginButton.hidden = false
        registerButton.hidden = false
        
        usernameView.delegate = self
        passwordView.delegate = self
        checkLoginButtonState()
    }

    @IBAction func login(sender: AnyObject) {
        
        PFUser.logInWithUsernameInBackground(usernameView.text!, password: passwordView.text!) { (user, error) -> Void in
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
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        checkLoginButtonState()
        return true
    }
    
    func checkLoginButtonState(){
        let hasMissingField = usernameView.text == ""
            || passwordView.text == ""
        
        loginButton.enabled = !hasMissingField
        loginButton.userInteractionEnabled = !hasMissingField
    }
    
    private func configureBackground() {
        let backgroundGradient = CAGradientLayer()
        let colorTop = UIColor(red:0.90, green:0.36, blue:0.26, alpha:1.0).CGColor
        let colorBottom = UIColor(red:0.91, green:0.21, blue:0.29, alpha:1.0).CGColor
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, atIndex: 0)
    }
}

