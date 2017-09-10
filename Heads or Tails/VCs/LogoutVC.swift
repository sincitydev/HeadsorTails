//
//  LogoutVCViewController.swift
//  Heads or Tails
//
//  Created by Amanuel Ketebo on 9/1/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class LogoutVC: UIViewController
{
    private var firebaseManager = FirebaseManager()
    
    init()
    {
        super.init(nibName: nil, bundle: nil)
        
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBAction func logout()
    {
        firebaseManager.logout {_ in }
    }
    
    @IBAction func cancel()
    {
        dismiss(animated: true, completion: nil)
    }
}
