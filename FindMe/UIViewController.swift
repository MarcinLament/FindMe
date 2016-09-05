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
        if(view.window == nil){
            return
        }
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: completion))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    public func showAlert(title: String, message: String, positiveButtonText: String, negativeButtonText:String, positiveCompletion: ((UIAlertAction) -> Void)?, negativeCompletion: ((UIAlertAction) -> Void)?){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: negativeButtonText, style: .Default, handler: negativeCompletion))
        ac.addAction(UIAlertAction(title: positiveButtonText, style: .Default, handler: positiveCompletion))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func isValidEmail(text: String) -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(text)
    }
    
    func configureBackground(colorTop:CGColor, colorBottom:CGColor) {
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, atIndex: 0)
    }
    
    func styleButton(uiButton: UIView, colorTop: CGColor, colorBottom: CGColor, roundedCorners: Bool){
        uiButton.tintColor = UIColor.whiteColor()
        
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.frame.size = uiButton.frame.size
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        
        if(roundedCorners){
            backgroundGradient.cornerRadius = 6
        }
        uiButton.layer.insertSublayer(backgroundGradient, atIndex: 0)
    }
    
    func stylePrimaryBackground(){
        configureBackground(UIColor.customPrimaryBgColorTop().CGColor, colorBottom: UIColor.customPrimaryBgColorBottom().CGColor)
    }
    
    func stylePrimaryButton(uiButton: UIView, roundedCorners: Bool){
        styleButton(uiButton, colorTop: UIColor.customPrimaryButtonColorTop().CGColor, colorBottom: UIColor.customPrimaryButtonColorBottom().CGColor, roundedCorners: roundedCorners)
    }
}