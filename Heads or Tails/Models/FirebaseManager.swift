//
//  FirebaseManager.swift
//  Heads or Tails
//
//  Created by Amanuel Ketebo on 8/29/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

class FirebaseManager
{
    static let shared = FirebaseManager()
    
    // ref property needs to be a lazy var because when initializing
    // Firebase complains that configure() hasn't been called when it
    // acutally is being called in the AppDelegate
    
    lazy var ref: DatabaseReference = {
        return Database.database().reference()
    }()
    
    func login(email: String, password: String, authCallback: AuthResultCallback?)
    {
        Auth.auth().signIn(withEmail: email, password: password, completion: authCallback)
    }
    
    func saveNewPlayer(_ player: Player)
    {
        let playerData = ["coins": player.coins] as [String : Any]
        
        ref.child("players").child(player.uid).setValue(playerData)
    }
    
    func logout()
    {
        do
        {
            try Auth.auth().signOut()
        }
        catch
        {
            print("\n\n\nSomething went wrong when logging out\n\n\n")
        }
    }
}
