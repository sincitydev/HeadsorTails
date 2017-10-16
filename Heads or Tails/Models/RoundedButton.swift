//
//  RoundedButton.swift
//  Heads or Tails
//
//  Created by Amanuel Ketebo on 9/1/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButton: UIButton {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
}
