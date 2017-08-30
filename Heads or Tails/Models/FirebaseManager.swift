//
//  FirebaseManager.swift
//  Heads or Tails
//
//  Created by Amanuel Ketebo on 8/29/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth

class FirebaseManager
{
    static let shared = FirebaseManager()
    
    // needs to be a lazy var because when initializing
    // Firebase complains that configure() hasn't been
    // called when it acutally is being called in the
    // AppDelegate
    lazy var ref = {
        return Database.database().reference()
    }
}
