//
//  InputTextView.swift
//  FindMe
//
//  Created by Marcin Lament on 01/09/2016.
//  Copyright © 2016 Marcin Lament. All rights reserved.
//

import Foundation
import UIKit

class UIInputTextView: UIView{
    
    let margin = 8 as CGFloat
    var textField: UITextField?
    
    func setStyle(imageName: String?, textPlaceholder: String, isPassword:Bool){
        
        //set rounded background
        backgroundColor = UIColor.whiteColor()
        layer.cornerRadius = 6.0
        clipsToBounds = true
        
        //add imageView
        if(imageName != nil){
            let img = UIImage(named:imageName!)
            
            let imageSize = self.frame.height - 2*margin
            let imageView = UIImageView()
            imageView.frame = CGRectMake(margin, margin, imageSize, imageSize)
            
            imageView.backgroundColor = UIColor.customPinkColor()
            imageView.layer.cornerRadius = 6.0
            imageView.clipsToBounds = true
            imageView.image = img?.imageWithInsets(90)
            
            self.addSubview(imageView)
            
            
            //add text field
            textField = UITextField()
            if(isPassword){
                textField!.secureTextEntry = true;
            }
            textField!.autocapitalizationType = .None
            textField!.autocorrectionType = .No
            textField!.placeholder = textPlaceholder
            self.addSubview(textField!)
            
            textField!.translatesAutoresizingMaskIntoConstraints = false
            let horizonalContraints = NSLayoutConstraint(item: textField!, attribute:
                        .Leading, relatedBy: .Equal, toItem: imageView,
                                        attribute: .Trailing, multiplier: 1.0,
                                        constant: 8)
            
            let horizonal2Contraints = NSLayoutConstraint(item: self, attribute:
                        .Trailing, relatedBy: .Equal, toItem: textField,
                                         attribute: .Trailing, multiplier: 1.0, constant: 8)
            
            NSLayoutConstraint.activateConstraints([horizonalContraints, horizonal2Contraints])
            
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-8-[subview]-8-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": textField!]))
                
        }else{
            textField = UITextField()
            if(isPassword){
                textField!.secureTextEntry = true;
            }
            textField!.autocapitalizationType = .None
            textField!.autocorrectionType = .No
            textField!.placeholder = textPlaceholder
            self.addSubview(textField!)
            
            textField!.translatesAutoresizingMaskIntoConstraints = false
            
            let horizonalContraints = NSLayoutConstraint(item: self, attribute:
                .Leading, relatedBy: .Equal, toItem: textField,
                           attribute: .Leading, multiplier: 1.0, constant: -8)
            
            let horizonal2Contraints = NSLayoutConstraint(item: self, attribute:
                .Trailing, relatedBy: .Equal, toItem: textField,
                           attribute: .Trailing, multiplier: 1.0, constant: -8)
            
            NSLayoutConstraint.activateConstraints([horizonalContraints, horizonal2Contraints])
            
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-8-[subview]-8-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": textField!]))
        }
        
    }
    
    func getText()->String{
        return (textField?.text)!
    }
}