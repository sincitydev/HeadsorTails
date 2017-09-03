//
//  UIView+Extension.swift
//  Heads or Tails
//
//  Created by Amanuel Ketebo on 9/2/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit
import Foundation

extension UIView
{
    func fadeIn(duration: TimeInterval)
    {
        self.alpha = 0
        
        UIView.animate(withDuration: duration) { 
            self.alpha = 1
        }
    }
    
    func fadeOut(duration: TimeInterval)
    {
        UIView.animate(withDuration: duration) { 
            self.alpha = 0
        }
    }
}
