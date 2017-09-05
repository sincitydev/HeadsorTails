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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBAction func touchedLogout(_ sender: UIBarButtonItem)
    {
        let logoutVC = LogoutVC()
        
        present(logoutVC, animated: true, completion: nil)
    }
}
