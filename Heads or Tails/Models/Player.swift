//
//  Player.swift
//  Heads or Tails
//
//  Created by Amanuel Ketebo on 8/29/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import Foundation

class Player
{
    var uid: String
    var username: String
    var coins: Int
    
    init(uid: String, username: String, coins: Int)
    {
        self.uid = uid
        self.username = username
        self.coins = coins
    }
}
