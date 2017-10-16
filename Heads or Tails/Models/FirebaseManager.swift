//
//  FirebaseManager.swift
//  Heads or Tails
//
//  Created by Amanuel Ketebo on 8/29/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

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

struct FirebaseLiterals {
    static let players = "players"
    static let uid = "uid"
    static let username = "username"
    static let coins = "coins"
}

class FirebaseManager {
    static let shared = FirebaseManager()
    let notificationCenter = NotificationCenter.default
    
    typealias AuthErrorCallback = (AuthError) -> Void
    
    // ref property needs to be a lazy var because when initializing
    // Firebase complains that configure() hasn't been called when it
    // acutally is being called in the AppDelegate
    
    lazy var ref: DatabaseReference = {
        return Database.database().reference()
    }()
    
    // MARK: - Login and logout methods
    
    func login(email: String, password: String, authCallback: AuthResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: authCallback)
    }
    
    func logout(completion: (AuthError?) -> Void) {
        do {
            try Auth.auth().signOut()
            notificationCenter.post(name: .authenticationDidChange, object: nil)
            completion(nil)
        }
        catch {
            completion(.couldntLogout)
        }
    }
    
    func checkUsername(_ newPlayerUsername: String, completion: @escaping (AuthError?) -> Void) {
        ref.child(FirebaseLiterals.players).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let playerInfos = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            
            if playerInfos.contains(where: { (playerInfo: (takenUsername: String, value: Any)) -> Bool in
                return playerInfo.takenUsername == newPlayerUsername
            }) {
                completion(.usernameAlreadyInUse)
            }
            else {
                completion(nil)
            }
        })
    }
    
    // MARK: - Saving and fetching data methods
    
    func saveNewPlayer(_ player: Player) {
        let playerData = [FirebaseLiterals.uid: player.uid,
                          FirebaseLiterals.username: player.username,
                          FirebaseLiterals.coins: player.coins] as [String : Any]
        
        ref.child(FirebaseLiterals.players).child(player.username).setValue(playerData)
    }
    
    func fetchPlayers(completion: @escaping ([Player]?, Error?) -> Void) {
        ref.child(FirebaseLiterals.players).observeSingleEvent(of: .value, with: { (snapshot) in
            if let firebasePlayers = snapshot.value as? [String: Any] {
                var players: [Player] = []
                
                firebasePlayers.forEach({ (username: String, player: Any) in
                    guard let playerInfo = player as? [String: Any] else { return }
                    if let player = Player(playerInfo) {
                        players.append(player)
                    }
                })
                
                completion(players, nil)
            }
        }) { (error) in
            completion(nil, error)
        }
    }
}
