//
//  SignupVC.swift
//  Heads or Tails
//
//  Created by Amanuel Ketebo on 8/27/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignupVC: UIViewController {

    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private let firebaseManager = FirebaseManager.shared
    
    var delegate: AuthenticationDelegate?
    
    var validInput: Bool
    {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        if email.isEmpty || password.isEmpty
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews()
    {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        errorMessageLabel.alpha = 0
    }
    
    @IBAction func signup()
    {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        if validInput
        {
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] (user, error) in
                
                if let error = error, let authError = AuthErrorCode(rawValue: error._code)
                {
                    self?.showLoginError(authError.description)
                }
                else
                {
                    guard let user = user else { return }
                    
                    let player = Player(uid: user.uid, coins: 100)
                    
                    self?.firebaseManager.saveNewPlayer(player)
                    self?.delegate?.authenticationDidChange()
                }
            }
        }
        else
        {
            showLoginError("Invalid input")
        }
    }
    private func showLoginError(_ message: String)
    {
        errorMessageLabel.text = message
        errorMessageLabel.fadeIn(duration: 0.2)
    }
}
