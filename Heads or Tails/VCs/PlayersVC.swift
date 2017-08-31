//
//  PlayersVC.swift
//  Heads or Tails
//
//  Created by Amanuel Ketebo on 8/29/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class PlayersVC: UIViewController
{    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews()
    {
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = UIColor(red:0.29, green:0.56, blue:0.89, alpha:1.0)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "logout"), style: .plain, target: self, action: #selector(logout))
    }
    
    @objc private func logout()
    {
        print("YOOOO\n\n\n\n")
    }
}
