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
    var localPlayer: Player?
    var opponentPlayer: Player?
    
    var localBet: Int?
    var opponentBet: Int?
    
    var localMove: String?
    var opponentMove: String?
    
    var finishedSettingUp = false
    
    var gameUID: String? {
        didSet {
            setupCoins()
            fetchBetsAndMoves()
            firebaseManager.createLisenerOn(gameKey: gameUID!, completion: { (_) in
                self.updateBetsandMoves()
            })
        }
    }
    var status = ""
    
    let notificationCeneter = NotificationCenter.default
    let firebaseManager = FirebaseManager.instance

    private func fetchBetsAndMoves() {
        if gameUID != nil {
            if localPlayer != nil && opponentPlayer != nil {
                
                self.updateBetsandMoves()
            }
            self.finishedSettingUp = true
        }
    }
    
    private func updateBetsandMoves() {
        firebaseManager.getBet(forPlayerUID: (localPlayer?.uid)!, gameKey: gameUID!, completion: { (bet) in
            self.localBet = bet
            self.notificationCeneter.post(name: NSNotification.Name.init(rawValue: "gameUpdated"), object: nil)
        })
        firebaseManager.getBet(forPlayerUID: (opponentPlayer?.uid)!, gameKey: gameUID!, completion: { (bet) in
            self.opponentBet = bet
            self.notificationCeneter.post(name: NSNotification.Name.init(rawValue: "gameUpdated"), object: nil)
        })
        firebaseManager.getMove(forPlayerIUD: (localPlayer?.uid)!, gameKey: gameUID!, completion: { (move) in
            self.localMove = move
            self.notificationCeneter.post(name: NSNotification.Name.init(rawValue: "gameUpdated"), object: nil)
        })
        firebaseManager.getMove(forPlayerIUD: (opponentPlayer?.uid)!, gameKey: gameUID!, completion: { (move) in
            self.opponentMove = move
            self.notificationCeneter.post(name: NSNotification.Name.init(rawValue: "gameUpdated"), object: nil)
        })
    }
        
    func setupPlayers(localPlayer: Player, opponentPlayer: Player) {
        self.localPlayer = localPlayer
        self.opponentPlayer = opponentPlayer
        fetchBetsAndMoves()
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
        firebaseManager.updateStatus(status: status, gameUID: gameUID!)
        
    }
    
    func addMove(_ move: Move, for player: Player) {
        
    }

    func getGameDescription() -> String {
        if finishedSettingUp {
            if localBet == 0 {
                return "Enter your bet"
            } else if opponentBet == 0 {
                return "Waiting for opponent to bet"
            } else {
                return "We are on the first move"
            }
        } else {
            return "Waiting on server..."
        }
    }
}
