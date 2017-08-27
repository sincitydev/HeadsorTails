//
//  UIView+Extension.swift
//  Heads or Tails
//
//  Created by Amanuel Ketebo on 8/26/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit
import Foundation

extension UIView
{
    @IBInspectable
    var cornerRadius: CGFloat
    {
        get { return self.layer.cornerRadius }
        set { self.layer.cornerRadius = newValue }
    }
}
