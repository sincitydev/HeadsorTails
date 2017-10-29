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
    static let instance = FirebaseManager()
    
    let notificationCenter = NotificationCenter.default
    
    func login(email: String, password: String, authCallBack: AuthResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: authCallBack)
    }
    
    func logout(completion: (AuthError?) -> Void) {
        do {
            let currentUserUID = Auth.auth().currentUser?.uid
            
            Literals.users.child(currentUserUID!).updateChildValues(["online": false])
            
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
        var playerArray = [Player]()
        
        Literals.users.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            for snap in snapshot {
                if snap.key != Auth.auth().currentUser?.uid {
                    guard let username = snap.childSnapshot(forPath: "username").value as? String,
                        let coins = snap.childSnapshot(forPath: "coins").value as? Int,
                        let online = snap.childSnapshot(forPath: "online").value as? Bool else { return }
                    
                    let player = Player(uid: snap.key, username: username, coins: coins, online: online)
                    playerArray.append(player)
                }
            }
            DispatchQueue.main.async {
                completion(playerArray)
            }
        })
    }
    
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

    func createGame(oppenentUID: String, initialBet: Int) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        getGameKeyWith(playerUID: userUID, playerUId: oppenentUID, completion: { (existingGame) in
            if existingGame == nil {
                let gamePlayers = [userUID: ["bet": initialBet], oppenentUID: ["bet": 0], "Status": "invite pending"] as [String : Any]
                
                Literals.games.childByAutoId().updateChildValues(gamePlayers)
            } else {
                print("Game already exists")
            }
        })
    }

    // function that returns the key for a specific game that contains the two players
    func getGameKeyWith(playerUID player1: String, playerUId player2: String, completion: @escaping (_ gameKey: String?)->()) {
        var gameKey: String? = nil
        Literals.games.observeSingleEvent(of: .value, with: { (gamesSnapshot) in
            guard let gamesSnapshot = gamesSnapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            
            gamesSnapshot.forEach({ (snap) in
                guard let gameDetails = snap.value as? [String: Any] else {
                    completion(nil)
                    return
                }
                
                if gameDetails.keys.contains(player1) && gameDetails.keys.contains(player2) {
                    gameKey = snap.key
                    completion(gameKey)
                    return
                }
            })
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
    
    func postOnlineStatus(_ onlineStatus: Bool) {
        guar d let currentUserUID = Auth.auth().currentUser?.uid else { return }
        Literals.users.child(currentUserUID).updateChildValues(["online": onlineStatus])
    }
    
    // TODO - Get Games for players (uid)
    func getGames() {
        
    }
    
    // TODO - Get current currency
    func getCurrency(forPlayerUID player: String) {
        
    }
    
    // TODO - Update currecy for uid
    func updateCurrency(forPlayerUID player: String) {
        
    }
}
