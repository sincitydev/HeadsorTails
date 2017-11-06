//
//  FirebaseManager.swift
//  Heads or Tails
//
//  Created by Joshua Ramos on 10/15/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import Foundation
import Firebase

enum AuthError {
    case usernameAlreadyInUse
    case couldntLogout
    case invalidFirebaseData
    
    var description: String {
        switch self {
        case .usernameAlreadyInUse: return "Username already in use"
        case .couldntLogout: return "Couldn't log out"
        case .invalidFirebaseData: return "Invalid Firebase data"
        }
    }
}

struct Literals {
    static let base = DB_Base
    static let users = DB_Base.child("users")
    static let games = DB_Base.child("games")
}

fileprivate let DB_Base = Database.database().reference()

class FirebaseManager {
    // MARK: - Properties
    static let instance = FirebaseManager()
    
    var uid: String {
        guard let currentUser = Auth.auth().currentUser else {
            return ""
        }
        
        return currentUser.uid
    }
    
    let notificationCenter = NotificationCenter.default
    
    // MARK: - Authentication methods
    func login(email: String, password: String, authCallBack: AuthResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: authCallBack)
    }
    
    func logout(completion: (AuthError?) -> Void) {
        guard let _ = Auth.auth().currentUser else {
            completion(.couldntLogout)
            return
        }
        
        do {
            postOnlineStatus(false)
            
            try Auth.auth().signOut()
            notificationCenter.post(name: .authenticationDidChange, object: nil)
            completion(nil)
        }
        catch {
            completion(.couldntLogout)
        }
    }
    
    func checkUsername(_ newPlayerUsername: String, completion: @escaping (AuthError?) -> Void) {
        Literals.users.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let playerInfos = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            
            // Make this way more readable!
            
            if playerInfos.contains(where: { (uid, userData) -> Bool in
                if let userInfo = userData as? [String: Any],
                    let takenUsername = userInfo["username"] as? String {
                    return takenUsername == newPlayerUsername
                }
                return false
            }) {
                completion(.usernameAlreadyInUse)
            } else {
                completion(nil)
            }
        })
    }
    
    func saveNewUser(_ player: Player) {
        let playerData = ["username": player.username,
                          "coins": player.coins] as [String : Any]
        
        Literals.users.child(player.uid).updateChildValues(playerData)
    }
    
    
    func getPlayers(completion: @escaping (_ playersArray: [Player]) -> ()) {
        Literals.users.observeSingleEvent(of: .value, with: { (snapshot) in
            var playerArray = [Player]()
            
            if let users = snapshot.value as? [String: Any] {
                for user in users {
                    if user.key != Auth.auth().currentUser?.uid {
                        if let userInfo = user.value as? [String: Any],
                            let player = Player(uid: user.key, userInfo) {
                            playerArray.append(player)
                        }
                    }
                }
                DispatchQueue.main.async {
                    completion(playerArray)
                }
            }
            else {
                // Later on down the line create an error to pass back
                consolePrint("Oh no!")
            }
        })
    }
    
    func getPlayerInfoFor(uid: String, completion: @escaping (_ username: Player) -> ()) {
        Literals.users.child(uid).observeSingleEvent(of: .value, with: { (userSnapshot) in
            guard let userSnapshot = userSnapshot.value as? [String: Any] else { return }
            guard let username = userSnapshot["username"] as? String else { return }
            guard let coins = userSnapshot["coins"] as? Int else { return }
            guard let online = userSnapshot["online"] as? Bool else { return }
            let player = Player(uid: uid, username: username, coins: coins, online: online)
            completion(player)
        })
    }

    //username
    func searchPlayers(searchQuery: String, completion: @escaping (_ userSeachArray: [Player]) -> ()) {
        var players = [Player]()
        
        Literals.users.observe(.value, with: { (snapshot) in
            guard let userSnapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            for user in userSnapshot {
                let username = user.childSnapshot(forPath: "username").value as! String
                if username.contains(searchQuery) == true && user.key != Auth.auth().currentUser?.uid {
                    guard let coins = user.childSnapshot(forPath: "coins").value as? Int else { return }
                    guard let online = user.childSnapshot(forPath: "online").value as? Bool else { return }
                    let player = Player(uid: user.key, username: username, coins: coins, online: online)
                    players.append(player)
                }
            }
            DispatchQueue.main.async {
                completion(players)
            }
        })
    }

    func createGame(oppenentUID: String, initialBet: Int) -> String {
        guard let userUID = Auth.auth().currentUser?.uid else { return "MISSING USER UID" }
        let gamePlayers = [userUID: ["bet": initialBet], oppenentUID: ["bet": initialBet]] as [String : Any]
        let autoId = Literals.games.childByAutoId().key
        Literals.games.child(autoId).setValue(gamePlayers)
        return autoId
    }

    // function that returns the key for a specific game that contains the two players
    func getGameKeyWith(playerUID player1: String, playerUID player2: String, completion: @escaping (_ gameKey: String?)->()) {
        var gameKey: String? = nil
        Literals.games.observeSingleEvent(of: .value, with: { (gamesSnapshot) in
            guard let gamesSnapshot = gamesSnapshot.value as? [String: Any] else {
                completion(nil) // should print error instead
                return
            }
            
            gamesSnapshot.forEach({ (snap) in
                guard let gameDetails = snap.value as? [String: Any] else {
                    return
                }

                if gameDetails.keys.contains(player1) && gameDetails.keys.contains(player2) {
                    gameKey = snap.key
                    return
                }
            })
            completion(gameKey)
        })
    }
    
    func getOpponentsFor(currentPlayerUID: String, completion: @escaping(_ playerUids: [String])->()) {
        var playerUids = [String]()
        Literals.games.observeSingleEvent(of: .value, with: { (returnedGames) in
            guard let returnedGames = returnedGames.value as? [String: Any] else {
                completion(playerUids)
                return
            }
            for game in returnedGames {
                guard let gameDetails = game.value as? [String: Any] else { return }
             
                if gameDetails.keys.contains(currentPlayerUID) {
                    for key in gameDetails.keys {
                        if !(key == currentPlayerUID || key == "status") {
                            playerUids.append(key)
                        }
                    }
                }
            }
            completion(playerUids)
        })
    }
    
    func updateBet(forPlayerUID player: String, gameKey: String, bet: Int) {
        Literals.games.child(gameKey).observeSingleEvent(of: .value, with: { (gameSnapshot) in
            guard let gameSnapshot = gameSnapshot.value as? [String: Any] else { return }
            
            if gameSnapshot.keys.contains(player) {
                let bet = ["bet": bet]
                Literals.games.child(gameKey).child(player).updateChildValues(bet)
            }    
        })
    }
    
    func updateStatus(status: String, gameUID: String) {
        Literals.games.child(gameUID).observeSingleEvent(of: .value, with: { (gameSnapshot) in
            guard let gameSnapshot = gameSnapshot.value as? [String: Any] else { return }
            guard let returnStatus = gameSnapshot["status"] as? String else { return }
            if returnStatus == "needs key" {
                Literals.games.child(gameUID).updateChildValues(["status": status])
            }
        })
    }
    
    func getBet(forPlayerUID player: String, gameKey: String, completion: @escaping (_ bet: Int)->()) {
        Literals.games.child(gameKey).child(player).observeSingleEvent(of: .value, with: { (gameSnapshot) in
            guard let gameSnapshot = gameSnapshot.value as? [String: Any] else { return }
            guard let bet = gameSnapshot["bet"] as? Int else { return }
            completion(bet)
        })
    }
    
    func getMove(forPlayerIUD player: String, gameKey: String, completion: @escaping (_ move: String?) -> ()) {
        Literals.games.child(gameKey).child(player).observeSingleEvent(of: .value, with: { (gameSnapshot) in
            guard let gameSnapshot = gameSnapshot.value as? [String: Any] else { return }
            guard let move = gameSnapshot["move"] as? String else {
                completion(nil)
                return
            }
            completion(move)
        })
    }
    
    func listen(on gameKey: String, completion: @escaping ([String: Any]) -> Void) {
        Literals.games.child(gameKey).observe(.value, with: { (snapshot) in
            if let snapshotData = snapshot.value as? [String: Any] {
                completion(snapshotData)
            }
        })
    }
    
    func getGame(for gameKey: String, completion: @escaping ([String: Any]) -> Void) {
        Literals.games.observe(.value, with: { (snapshot) in
            if let snapshotData = snapshot.value as? [String: Any],
                let gameDetails = snapshotData[gameKey] as? [String: Any] {
                completion(gameDetails)
            }
        })
    }
    
    func postOnlineStatus(_ onlineStatus: Bool) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
        Literals.users.child(currentUserUID).updateChildValues(["online": onlineStatus])
    }
    
    func updateRound(for gameKey: String, with round: Int) {
        Literals.games.child(gameKey).updateChildValues(["round": round])
    }
    
    func addMove(_ move: Move, for player: Player, gameUID: String) {
        Literals.games.child(gameUID).observeSingleEvent(of: .value, with: { (gameSnapshot) in
            guard let gameSnapshot = gameSnapshot.value as? [String: Any] else { return }
            guard let playerInfo = gameSnapshot[player.uid] as? [String: Any] else { return }
            guard var moves = playerInfo["move"] as? String else {
                Literals.games.child(gameUID).child(player.uid).updateChildValues(["move": move.rawValue])
                return }
            
            moves += move.rawValue
            Literals.games.child(gameUID).child(player.uid).updateChildValues(["move": moves])
            
        })
    }
}
