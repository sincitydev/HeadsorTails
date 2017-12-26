//
//  AuthHelper.swift
//  Heads or Tails
//
//  Created by Amanuel Ketebo on 10/19/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import Foundation
import UIKit

protocol AuthHelper { }

extension AuthHelper {
    func showLoginError(_ label: UILabel?, with message: String) {
        guard let label = label else { return }
        
        label.text = message
        label.fadeIn(duration: 0.2)
    }
    
    func hideLoginError(_ label: UILabel?) {
        guard let label = label else { return }
        
        label.text = ""
        label.fadeOut(duration: 0.2)
    }
    
    func validInput(email: String, password: String) -> Bool {
        if email.isEmpty || password.isEmpty {
            return false
        }
        else {
            return true
        }
    }
    
    func validInput(username: String, email: String, password: String, validUsername: Bool) -> Bool {
        if username.isEmpty || email.isEmpty || password.isEmpty || validUsername == false {
            return false
        }
        else {
            return true
        }
    }
}
