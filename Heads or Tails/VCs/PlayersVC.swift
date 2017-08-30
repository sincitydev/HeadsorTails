//
//  PlayersVC.swift
//  Heads or Tails
//
//  Created by Amanuel Ketebo on 8/29/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class PlayersVC: UIViewController {

    private var firebaseManager = FirebaseManager()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        firebaseManager.fetchPlayers(completion: nil)
    }
}
