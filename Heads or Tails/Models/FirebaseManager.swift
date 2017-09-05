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

enum AuthUsernameError
{
    case alreadyInUse
    case invalidFirebaseData
    
    var description: String
    {
        switch self
        {
        case .alreadyInUse: return "Username already in use"
        case .invalidFirebaseData: return "Invalid Firebase data returned"
        }
    }
}

struct FirebaseLiterals
{
    static let players = "players"
    static let coins = "coins"
}

class FirebaseManager
{
    static let shared = FirebaseManager()
    let notificationCenter = NotificationCenter.default
    
    typealias AuthUsernameCallback = (AuthUsernameError) -> Void
    
    // ref property needs to be a lazy var because when initializing
    // Firebase complains that configure() hasn't been called when it
    // acutally is being called in the AppDelegate
    
    lazy var ref: DatabaseReference = {
        return Database.database().reference()
    }()
    
    // MARK: - Login and logout methods
    
    func login(email: String, password: String, authCallback: AuthResultCallback?)
    {
        Auth.auth().signIn(withEmail: email, password: password, completion: authCallback)
    }
    
    func logout()
    {
        do
        {
            try Auth.auth().signOut()
            notificationCenter.post(name: .authenticationDidChange, object: nil)
        }
        catch
        {
            print("\n\n\nSomething went wrong when logging out\n\n\n")
        }
    }
    
    func checkUsername(_ newPlayerUsername: String, completion: @escaping (AuthUsernameError?) -> Void)
    {
        ref.child(FirebaseLiterals.players).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let playerInfos = snapshot.value as? [String: Any] else {
                completion(.invalidFirebaseData)
                return
            }
            
            if playerInfos.contains(where: { (playerInfo: (takenUsername: String, value: Any)) -> Bool in
                return playerInfo.takenUsername == newPlayerUsername
            })
            {
                completion(.alreadyInUse)
            }
            else
            {
                completion(nil)
            }
        })
    }
    
    // MARK: - Saving and fetching data methods
    
    func saveNewPlayer(_ player: Player)
    {
        let playerData = [FirebaseLiterals.coins: player.coins] as [String : Any]
        
        ref.child(FirebaseLiterals.players).child(player.username).setValue(playerData)
    }
}
