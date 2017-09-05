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

extension Notification.Name
{
    static let authenticationDidChange = Notification.Name.init("authenticationDidChange")
}

enum AuthUsernameError
{
    case alreadyInUse
    case invalidFirebaseData
}

struct FirebasePath
{
    static let players = "players"
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
    
    func checkUsername(_ newPlayerUsername: String, completion: @escaping (AuthUsernameError?) -> Void)
    {
        ref.child(FirebasePath.players).observeSingleEvent(of: .value, with: { (snapshot) in
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
    
    func login(email: String, password: String, authCallback: AuthResultCallback?)
    {
        Auth.auth().signIn(withEmail: email, password: password, completion: authCallback)
    }
    
    func saveNewPlayer(_ player: Player)
    {
        let playerData = ["coins": player.coins] as [String : Any]
        
        ref.child(FirebasePath.players).child(player.username).setValue(playerData)
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
}
