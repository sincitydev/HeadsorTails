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
    
    // Game status
    var status = ""
    var round = 0 {
        willSet {
            if round < newValue {
                localPlayerHasMoveForRound = false
                notificationCenter.post(name: .increaseRound, object: nil, userInfo: ["round": newValue])
            }
            
            if newValue == 6 {
                var localScore = 0
                var opponentScore = 0
                
                var statusArray = [String]()
                var localMoveArray = [String]()
                var opponentMoveArray = [String]()
                
                
                // Creating the arrays of characters
                for char in status {
                    let char = String(char)
                    statusArray.append(char)
                }
                
                for char in localMove! {
                    let char = String(char)
                    localMoveArray.append(char)
                }
                
                for char in opponentMove! {
                    let char = String(char)
                    opponentMoveArray.append(char)
                }
                
                // calculating scores
                for i in 0..<5 {
                    if statusArray[i] == localMoveArray[i] {
                        localScore += 1
                    }
                    if statusArray[i] == opponentMoveArray[i] {
                        opponentScore += 1
                    }
                }
                
                // determine winner
                if localScore == opponentScore {
                    // draw
                    print("Draw")
                } else if localScore > opponentScore {
                    // win
                    print("Won")
                } else if localScore < opponentScore {
                    // lose
                    print("Lost")
                }
            }
        }
    }
    var localPlayerHasMoveForRound = false
    
    // Player bets
    var localBet = 0 {
        willSet {
            if localBet < newValue && opponentBet != 0 {
                round += 1
            }
        }
    }
    var opponentBet = 0
    
    // Player moves
    var localMove: String? {
        willSet {
            if let newValue = newValue, let opponentMove = opponentMove {
                if localBet > 0 && opponentBet > 0 && newValue.count == round && opponentMove.count == round {
                    round += 1
                }
            }
        }
    }
    var opponentMove: String?
    
    var gameUID: String {
        didSet {
            setupCoins()
        }
    }
    
    let firebaseManager = FirebaseManager.instance
    let notificationCenter = NotificationCenter.default
    
    init(gameID: String, localPlayer: Player, opponent: Player) {
        self.gameUID = gameID
        self.localPlayer = localPlayer
        self.opponentPlayer = opponent
    }

    private func setupCoins() {
        for _ in 1...5 {
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
        localPlayerHasMoveForRound = true
        firebaseManager.addMove(move, for: player, gameUID: gameUID)
    }

    func getGameDescription() -> String {
        if localBet == 0 {
            return "Enter your bet"
        } else if opponentBet == 0 {
            return "Waiting for opponent to bet"
        } else if localMove == nil {
            return "Select your coin"
        } else if opponentMove == nil {
            return "Waiting on opponent to move"
        } else if (localMove?.count ?? 0) < round {
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
        print("******Moves: \(localMove ?? "")")
        print("---Opponent player: \(opponentPlayer.username)")
        print("******Bet: \(opponentBet)")
        print("******Moves: \(opponentMove ?? "")")
        print("\n")
    }
}
