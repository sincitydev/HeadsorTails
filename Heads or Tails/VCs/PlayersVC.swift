//
//  PlayersVC.swift
//  Heads or Tails
//
//  Created by Amanuel Ketebo on 8/29/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit
import FirebaseAuth

class PlayersVC: UIViewController
{
    private var firebaseManager = FirebaseManager()
    var delegate: AuthenticationDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        createAuthListener()
    }
    
    private func createAuthListener()
    {
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if user == nil
            {
                self?.delegate?.authenticationDidChange()
            }
        }
    }
    
    @IBAction func touchedLogout(_ sender: UIBarButtonItem)
    {
        let logoutVC = LogoutVC()
        
        present(logoutVC, animated: true, completion: nil)
    }
    
    private func logout()
    {
        firebaseManager.logout()
    }
}
