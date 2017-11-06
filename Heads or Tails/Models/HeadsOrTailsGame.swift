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
    // Players
    var localPlayer: Player!
    var opponentPlayer: Player!
    var gameUID: String!
    
    // Game status
    var status = ""
    var round = 0
    
    // Player bets
    var localBet = 0
    var opponentBet = 0
    
    // Player moves
    var localMove = ""
    var opponentMove = ""
    
    let firebaseManager = FirebaseManager.instance
    let notificationCenter = NotificationCenter.default
    
    init(gameID: String, localPlayer: Player, opponent: Player) {
        self.gameUID = gameID
        self.localPlayer = localPlayer
        self.opponentPlayer = opponent
        firebaseManager.listen(on: gameUID) { [weak self] (gameDetails) in
            self?.round = gameDetails["round"] as? Int ?? 0
            self?.status = gameDetails["status"] as? String ?? ""
            
            guard let localDetails = gameDetails[(self?.localPlayer.uid)!] as? [String: Any] else { return }
            guard let opponentDetails = gameDetails[(self?.opponentPlayer.uid)!] as? [String: Any] else { return }
            
            self?.localBet = (localDetails["bet"] as? Int)!
            self?.opponentBet = (opponentDetails["bet"] as? Int)!
            
            if let localMove = localDetails["move"] as? String {
                self?.localMove = localMove
            }
            
            if let opponentMove = opponentDetails["move"] as? String {
                self?.opponentMove = opponentMove
            }
            self?.notificationCenter.post(name: NSNotification.Name.gameDidUpdate, object: nil)
        }
    }
    
    func addMove(_ move: Move, for player: Player) {
        if localMove.count < round && round != 6 {
            firebaseManager.addMove(move, for: player, gameUID: gameUID)
        }
    }

    func getGameDescription() -> String {
        if localBet == 0 {
            return "Enter your bet"
        } else if opponentBet == 0 {
            return "Waiting for opponent to bet"
        } else if round == 6 {
            var localScore = 0
            var opponentScore = 0
            var localMovesArray = [String]()
            var opponentMovesArray = [String]()
            var statusArray = [String]()
            
            for char in localMove {
                localMovesArray.append(String(char))
            }
            
            for char in opponentMove {
                opponentMovesArray.append(String(char))
            }
            
            for char in status {
                statusArray.append(String(char))
            }
            
            for i in 0...4 {
                if statusArray[i] == localMovesArray[i] {
                    localScore += 1
                }
                if statusArray[i] == opponentMovesArray[i] {
                    opponentScore += 1
                }
            }
        
            if localScore == opponentScore {
                return "Draw!!!"
            } else if localScore > opponentScore {
                return "You Win!"
            } else {
                return "You Lost..."
            }
        
        } else if localMove == "" {
            return "Select your coin"
        } else if opponentMove == "" {
            return "Waiting on opponent to move"
        } else if localMove.count < round {
            return "Select your coin"
        } else {
            return "Waiting on opponent to move"
        }
    }
    
    func printState() {
        print("\n")
        print("Game between \(localPlayer.username) & \(opponentPlayer.username)")
        print("---Status: \(status)")
        print("---Round: \(round)")
        print("---Local player: \(localPlayer.username)")
        print("******Bet: \(localBet)")
        print("******Moves: \(localMove)")
        print("---Opponent player: \(opponentPlayer.username)")
        print("******Bet: \(opponentBet)")
        print("******Moves: \(opponentMove)")
        print("\n")
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
}
