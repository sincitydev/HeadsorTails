//
//  FirebaseManagerV2.swift
//  Heads or Tails
//
//  Created by Joshua Ramos on 10/15/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import Foundation
import Firebase

let DB_Base = Database.database().reference()

struct Literals {
    static let base = DB_Base
    static let users = DB_Base.child("users")
    static let games = DB_Base.child("games")
}

class FirebaseManagerV2 {
    static let instance = FirebaseManagerV2()
    
    // TODO - Create User
    func saveNewUser(_ player: Player) {
        let playerData = ["username": player.username,
                          "coins": player.coins] as [String : Any]
        
        Literals.users.child(player.uid).updateChildValues(playerData)
    }
    
    // TODO - Get Players
    func getPlayers(completion: @escaping (_ playersArray: [Player]) -> ()) {
        var playerArray = [Player]()
        
        Literals.users.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
            for snap in snapshot {
                if snap.key != Auth.auth().currentUser?.uid {
                    guard let username = snap.childSnapshot(forPath: "username").value as? String else { return }
                    guard let coins = snap.childSnapshot(forPath: "coins").value as? Int else { return }
                    let player = Player(uid: snap.key, username: username, coins: coins)
                    playerArray.append(player)
                }
            }
            DispatchQueue.main.async {
                completion(playerArray)
            }
        })
    }

   // TODO - Create Game (uid, uid)
    
    
    // TODO - Get Games for players (uid)

    
    // TODO - Get current currency
    
    // TODO - Update currecy for uid
}
