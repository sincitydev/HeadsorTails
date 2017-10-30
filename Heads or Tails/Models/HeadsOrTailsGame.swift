//
//  HeadsOrTailsBrain.swift
//  Heads or Tails
//
//  Created by Amanuel Ketebo on 10/29/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import Foundation
import Firebase

enum Move: String {
    case heads = "H"
    case tails = "T"
}

class HeadsOrTailsGame {
    var localPlayer: Player!
    var opponent: Player!
    var gameUID: String!
    var status = ""
    
    let firebaseManager = FirebaseManager.instance
    
    init(gameUID: String) {
        self.gameUID = gameUID
        setupCoins()
    }
    
    func setupPlayers(opponent: Player) {
        firebaseManager.getPlayerInfoFor(uid: (Auth.auth().currentUser?.uid)!) { (player) in
            self.localPlayer = player
        }
        self.opponent = opponent
    }

    private func setupCoins() {
        for _ in 0..<5 {
            let randomNumber = arc4random_uniform(2)
            if randomNumber == 0 {
                status += "H"
            } else {
                status += "T"
            }
        }
        
        firebaseManager.updateStatus(status: status, gameUID: gameUID)
    }
    
    func addMove(_ move: Move, for player: Player) {
        
    }
}
