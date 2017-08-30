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
    var coins: Int
    
    init(uid: String, coins: Int)
    {
        self.uid = uid
        self.coins = coins
    }
}
