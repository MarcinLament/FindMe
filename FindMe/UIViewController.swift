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
}