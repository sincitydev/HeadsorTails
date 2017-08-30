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

class FirebaseManager
{
    var ref: DatabaseReference!
    
    func fetchPlayers(completion: (([Player], Error) -> Void)?)
    {
        ref = Database.database().reference()
        
        ref.child("players").observeSingleEvent(of: .value, with: { (snapshot) in
            // Some code to get that snapshot
        }) { (error) in
            guard let completion = completion else { return }
            
            completion([], error)
        }
    }
}
