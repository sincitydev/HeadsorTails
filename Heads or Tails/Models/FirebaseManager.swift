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
    lazy var ref: DatabaseReference = {
        return Database.database().reference()
    }()
    
    func saveNewPlayer(_ player: Player)
    {
        let playerData = ["coins": player.coins] as [String : Any]
        
        ref.child("players").child(player.uid).setValue(playerData)
    }
}
