//
//  Player.swift
//  Heads or Tails
//
//  Created by Amanuel Ketebo on 8/29/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import Foundation

class Player {
    var uid: String
    var username: String
    var coins: Int
    var online: Bool
    
    init(uid: String, username: String, coins: Int, online: Bool) {
        self.uid = uid
        self.username = username
        self.coins = coins
        self.online = online
    }
}

extension Player {
    convenience init?(_ firebaseJSON: [String: Any]) {
        if let uid = firebaseJSON["uid"] as? String,
            let username = firebaseJSON["username"] as? String,
            let coins = firebaseJSON["coins"] as? Int,
            let online = firebaseJSON["online"] as? Bool {
            self.init(uid: uid, username: username, coins: coins, online: online)
        }
        else {
            return nil
        }
    }
    
    convenience init?(uid: String,_ firebaseJSON: [String: Any]) {
        if let username = firebaseJSON["username"] as? String,
            let coins = firebaseJSON["coins"] as? Int,
            let online = firebaseJSON["online"] as? Bool {
            self.init(uid: uid, username: username, coins: coins, online: online)
        }
        else {
            return nil
        }
    }
}

