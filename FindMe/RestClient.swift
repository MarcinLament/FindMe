//
//  RestClient.swift
//  FindMe
//
//  Created by Marcin Lament on 04/09/2016.
//  Copyright © 2016 Marcin Lament. All rights reserved.
//

import Foundation

public class RestClient{
    
    func login(username: String, password: String, completionHandler: (user: , error)){
        PFUser.logInWithUsernameInBackground(usernameView.getText(), password: passwordView.getText()) { (user, error) -> Void in
            self.activityView.stopAnimating()
            
            if error == nil {
                self.openMapViewController()
            } else {
                self.showAlert("Error", message: error!.localizedDescription, completion: nil)
            }
        }
    }
}