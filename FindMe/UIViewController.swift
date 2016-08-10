//
//  UIViewController.swift
//  OnTheMap
//
//  Created by Marcin Lament on 04/06/2016.
//  Copyright © 2016 Marcin Lament. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
    
    public func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)?){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: completion))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    public func showAlert(title: String, message: String, positiveButtonText: String, negativeButtonText:String, positiveCompletion: ((UIAlertAction) -> Void)?, negativeCompletion: ((UIAlertAction) -> Void)?){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: positiveButtonText, style: .Default, handler: positiveCompletion))
        ac.addAction(UIAlertAction(title: negativeButtonText, style: .Default, handler: negativeCompletion))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func isValidEmail(text: String) -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(text)
    }
}