//
//  AuthenticationVC.swift
//  Heads or Tails
//
//  Created by Amanuel Ketebo on 8/26/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class LoginVC: UIViewController
{
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var userLoggingIn = false
    
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
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        errorMessageLabel.isHidden = true
    }
}
