//
//  FirebaseManager.swift
//  Heads or Tails
//
//  Created by Joshua Ramos on 10/15/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import Foundation
import Firebase

enum DatabaseError: Error {
    case fetchingError
    case parsingError
    case noPlayersListener
    case invalidGameKey
    case missingUID
    case usernameInUse
    case couldNotLogout
    
    var localizedDescription: String {
        switch self {
        case .usernameInUse: return "Username in use"
        case .couldNotLogout: return "Could not logout"
        default: return ""
        }
    }
}

enum DatabaseKeys: String {
    case users
    case games
    case username
    case coins
    case online
    case bet
    case status
    case round
    case move
}

struct Literals {
    static let base = DB_Base
    static let users = DB_Base.child(DatabaseKeys.users.rawValue)
    static let games = DB_Base.child(DatabaseKeys.games.rawValue)
}

fileprivate let DB_Base = Database.database().reference()

class FirebaseManager {
    // MARK: - Properties
    
    var uid: String {
        guard let currentUser = Auth.auth().currentUser else { return "" }
        return currentUser.uid
    }
    private var playersListenerID: Int?
    private let notificationCenter = NotificationCenter.default
    
    static let instance = FirebaseManager()
    
    // MARK: - Authentication methods
    
    func login(email: String, password: String, authCallBack: AuthResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: authCallBack)
    }
    
    func logout(completion: (DatabaseError?) -> Void) {
        guard let _ = Auth.auth().currentUser else {
            completion(.couldNotLogout)
            return
        }
        
        do {
            postOnlineStatus(false)
            
            try Auth.auth().signOut()
            notificationCenter.post(name: .authenticationDidChange, object: nil)
            completion(nil)
        }
        catch {
            completion(.couldNotLogout)
        }
    }
    
    func checkUsername(_ newPlayerUsername: String, completion: @escaping (DatabaseError?) -> Void) {
        Literals.users.observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            guard let strongSelf = self else { return }
            guard let playerInfos = snapshot.value as? [String: Any] else {
                completion(.parsingError)
                return
            }
            
            if strongSelf.usernameTaken(username: newPlayerUsername, playersData: playerInfos) {
                completion(.usernameInUse)
            } else {
                completion(nil)
            }
        })
    }
    
    // MARK: - Initial setup methods
    
    func saveNewPlayer(_ player: Player) {
        let playerData = [DatabaseKeys.username.rawValue: player.username,
                          DatabaseKeys.coins.rawValue: player.coins] as [String : Any]
        
        Literals.users.child(player.uid).updateChildValues(playerData)
    }
    
    // MARK: - Fetching methods
    
    // Player methods
    func fetchPlayers(completion: @escaping ([Player], DatabaseError?) -> Void) {
        Literals.users.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let users = snapshot.value as? [String: Any] else {
                completion([], .parsingError)
                return
            }
            
            var foundPlayers = [Player]()
            
            for user in users {
                if user.key != Auth.auth().currentUser?.uid {
                    if let userInfo = user.value as? [String: Any],
                        let player = Player(uid: user.key, userInfo) {
                        foundPlayers.append(player)
                    }
                }
            }
            
            completion(foundPlayers, nil)
        }) { (error) in
            completion([], .fetchingError)
        }
    }
    
    func fetchPlayerInfo(uid: String, completion: @escaping (Player?, DatabaseError?) -> Void) {
        Literals.users.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let playerData = snapshot.value as? [String: Any],
                let username = playerData[DatabaseKeys.username.rawValue] as? String,
                let coins = playerData[DatabaseKeys.coins.rawValue] as? Int,
                let online = playerData[DatabaseKeys.online.rawValue] as? Bool else {
                    completion(nil, .parsingError)
                    return
                    
            }
            
            let player = Player(uid: uid, username: username, coins: coins, online: online)
            completion(player, nil)
        })
    }
    
    // Game methods
    func fetchGame(playerUID player1: String, playerUID player2: String, completion: @escaping (String?, DatabaseError?) -> Void) {
        var gameKey: String?
        
        Literals.games.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let gamesData = snapshot.value as? [String: Any] else {
                completion(nil, DatabaseError.parsingError)
                return
            }
            
            gamesData.forEach({ (gameUID, gameData) in
                guard let gameDetails = gameData as? [String: Any] else {
                    completion(nil, DatabaseError.parsingError)
                    return
                }
                
                if gameDetails.keys.contains(player1) && gameDetails.keys.contains(player2) {
                    gameKey = gameUID
                } else {
                    completion(nil, nil)
                }
            })
            
            completion(gameKey, nil)
        })
    }
    
    func fetchOpponents(playerUID: String, completion: @escaping ([String], DatabaseError?) -> Void) {
        var playerUIDs: [String] = []
        
        Literals.games.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let foundGames = snapshot.value as? [String: Any] else {
                completion([], .parsingError)
                return
            }
            
            for game in foundGames {
                guard let gameDetails = game.value as? [String: Any] else {
                    completion([], .parsingError)
                    return
                }
                
                if gameDetails.keys.contains(playerUID) {
                    for key in gameDetails.keys {
                        if !(key == playerUID || key == DatabaseKeys.status.rawValue) {
                            playerUIDs.append(key)
                        }
                    }
                }
            }
            
            completion(playerUIDs, nil)
        })
    }
    
    func fetchBet(player: String, gameKey: String, completion: @escaping (Int?, DatabaseError?) -> Void) {
        Literals.games.child(gameKey).child(player).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let gameData = snapshot.value as? [String: Any],
                let bet = gameData[DatabaseKeys.bet.rawValue] as? Int else {
                    completion(nil, .parsingError)
                    return
            }
            
            completion(bet, nil)
        })
    }
    
    // MARK: - Update database methods
    
    func postOnlineStatus(_ onlineStatus: Bool) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
        
        Literals.users.child(currentUserUID).updateChildValues([DatabaseKeys.online.rawValue: onlineStatus])
    }
    
    func createGame(oppenentUID: String, initialBet: Int) -> String? {
        guard let userUID = Auth.auth().currentUser?.uid else { return nil }
        
        let gamePlayers = [userUID: [DatabaseKeys.bet.rawValue: initialBet],
                           oppenentUID: [DatabaseKeys.bet.rawValue: initialBet]] as [String : Any]
        let gameUID = Literals.games.childByAutoId().key
        
        Literals.games.child(gameUID).setValue(gamePlayers)
        
        return gameUID
    }
    
    func updateBet(playerUID: String, gameKey: String, bet: Int) {
        Literals.games.child(gameKey).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let gameData = snapshot.value as? [String: Any] else { return }
            
            if gameData.keys.contains(playerUID) {
                let bet = [DatabaseKeys.bet.rawValue: bet]
                
                Literals.games.child(gameKey).child(playerUID).updateChildValues(bet)
            }
        })
    }
    
    func addMove(_ move: Move, for player: Player, gameUID: String) {
        Literals.games.child(gameUID).observeSingleEvent(of: .value, with: { (gameSnapshot) in
            guard let gameSnapshot = gameSnapshot.value as? [String: Any],
                let playerInfo = gameSnapshot[player.uid] as? [String: Any],
                var moves = playerInfo[DatabaseKeys.move.rawValue] as? String else {
                    Literals.games.child(gameUID).child(player.uid).updateChildValues([DatabaseKeys.move.rawValue: move.rawValue])
                    return
            }
            
            moves += move.rawValue
            Literals.games.child(gameUID).child(player.uid).updateChildValues([DatabaseKeys.move.rawValue: moves])
        })
    }
    
    func updateRound(for gameKey: String, with round: Int) {
        Literals.games.child(gameKey).updateChildValues([DatabaseKeys.round.rawValue: round])
    }
    
    // MARK: - Listeners methods
    
    // Player listener
    func createPlayersListener(_ completion: @escaping ([Player], DatabaseError?) -> Void) {
        let listenerID = Literals.users.observe(.value) { (snapshot) in
            guard let users = snapshot.value as? [String: Any] else {
                completion([], .parsingError)
                return
            }
            
            var foundPlayers = [Player]()
            
            for user in users {
                if user.key != Auth.auth().currentUser?.uid {
                    if let userInfo = user.value as? [String: Any],
                        let player = Player(uid: user.key, userInfo) {
                        foundPlayers.append(player)
                    }
                }
            }
            
            DispatchQueue.main.async {
                completion(foundPlayers, nil)
            }
        }
        
        playersListenerID = Int(listenerID)
    }
    
    func removePlayerListener(_ completion: @escaping (DatabaseError?) -> Void) {
        if let listenerID = playersListenerID {
            Literals.users.removeObserver(withHandle: UInt(listenerID))
            
            DispatchQueue.main.async {
                completion(nil)
            }
        } else {
            DispatchQueue.main.async {
                completion(.noPlayersListener)
            }
        }
    }
    
    // Game listener
    func createGameListener(gameKey: String, completion: @escaping ([String: Any]?, DatabaseError?) -> Void) {
        Literals.games.child(gameKey).observe(.value, with: { (snapshot) in
            guard let snapshotData = snapshot.value as? [String: Any] else {
                DispatchQueue.main.async {
                    completion(nil, .parsingError)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(snapshotData, nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(nil, .invalidGameKey)
            }
        }
    }
    
    // MARK: - Helper methods
    
    private func usernameTaken(username: String, playersData: [String: Any]) -> Bool {
        return playersData.contains(where: { (playerUID, playerData) -> Bool in
            if let playerInfo = playerData as? [String: Any],
                let takenUsername = playerInfo["username"] as? String {
                return takenUsername == username
            } else {
                return false
            }
        })
    }
}
