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
        setupViews()
        createAuthListener()
    }
    
    private func setupViews()
    {
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = UIColor(red:0.29, green:0.56, blue:0.89, alpha:1.0)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "logout"), style: .plain, target: self, action: #selector(tappedLogout))
    }
    
    private func createAuthListener()
    {
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if user == nil
            {
                self?.delegate?.authenticationDidLogout()
            }
        }
    }
    
    @objc private func tappedLogout()
    {
        let logoutVC = LogoutVC()
        
        present(logoutVC, animated: true, completion: nil)
    }
    
    private func logout()
    {
        firebaseManager.logout()
    }
}
