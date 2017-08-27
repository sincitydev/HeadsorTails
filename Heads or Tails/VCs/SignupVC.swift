//
//  SignupVC.swift
//  Heads or Tails
//
//  Created by Amanuel Ketebo on 8/27/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class SignupVC: UIViewController {

    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews()
    {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        errorMessageLabel.isHidden = true
    }
}
