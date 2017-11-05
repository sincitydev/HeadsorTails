//
//  UIView+Extension.swift
//  Heads or Tails
//
//  Created by Amanuel Ketebo on 9/2/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit
import Foundation

extension UIView {
    func fadeIn(duration: TimeInterval) {
        self.alpha = 0
        
        UIView.animate(withDuration: duration) { 
            self.alpha = 1
        }
    }
    
    func fadeOut(duration: TimeInterval) {
        UIView.animate(withDuration: duration) { 
            self.alpha = 0
        }
    }
    
    static func hide(views: UIView...) {
        views.forEach { (view) in
            view.isHidden = true
        }
    }
    
    static func show(views: UIView...) {
        views.forEach { (view) in
            view.isHidden = false
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor {
        get {
            guard let borderColor = self.layer.borderColor else {
                return UIColor.clear
            }
            
            return UIColor(cgColor: borderColor)
        }
        set {
            self.layer.borderColor = newValue.cgColor
        }
    }
    
    @IBInspectable
    var corners: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
}
