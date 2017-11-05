//
//  UIStoryboard+Extension.swift
//  Heads or Tails
//
//  Created by Amanuel Ketebo on 8/29/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit
import Foundation

extension UIStoryboard {
    // Storyboards
    static let main = UIStoryboard.init(name: "Main", bundle: nil)
    static let auth = UIStoryboard.init(name: "Authentication", bundle: nil)
    // Segues
    static let gameVCSegue = "gameVCSegue"
}
