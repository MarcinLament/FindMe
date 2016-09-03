//
//  UIImage.swift
//  FindMe
//
//  Created by Marcin Lament on 01/09/2016.
//  Copyright © 2016 Marcin Lament. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func imageWithInsets(insetDimen: CGFloat) -> UIImage {
        return imageWithInset(UIEdgeInsets(top: insetDimen, left: insetDimen, bottom: insetDimen, right: insetDimen))
    }
    
    func imageWithInset(insets: UIEdgeInsets) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(
            CGSizeMake(self.size.width + insets.left + insets.right,
                self.size.height + insets.top + insets.bottom), false, self.scale)
        let origin = CGPoint(x: insets.left, y: insets.top)
        self.drawAtPoint(origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageWithInsets
    }
    
    
}

//extension UIView {
//    
//    /// Adds constraints to this `UIView` instances `superview` object to make sure this always has the same size as the superview.
//    /// Please note that this has no effect if its `superview` is `nil` – add this `UIView` instance as a subview before calling this.
//    func bindFrameToSuperviewBounds() {
//        guard let superview = self.superview else {
//            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
//            return
//        }
//        
//        self.translatesAutoresizingMaskIntoConstraints = false
//        superview.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[subview]-8-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": self]))
//        superview.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-8-[subview]-8-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": self]))
//    }
//    
//}