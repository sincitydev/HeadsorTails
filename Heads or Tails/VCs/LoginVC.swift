//
//  AuthenticationVC.swift
//  Heads or Tails
//
//  Created by Amanuel Ketebo on 8/26/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

protocol AuthenticationDelegate
{
    func authenticationDidChange()
}

// TODO: Looks like theres a similar code between the loginVC and signupVC
//       Is there anyway I can not repeat that same code in both VCs?

class LoginVC: UIViewController
{
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var delegate: AuthenticationDelegate?
    private var firebaseManager = FirebaseManager()
    
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
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = UIColor(red:0.29, green:0.56, blue:0.89, alpha:1.0)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        errorMessageLabel.alpha = 0
    }
    
    @IBAction func login()
    {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        
        if validInput
        {
            firebaseManager.login(email: email, password: password) { [weak self] (user, error) in
                if let error = error, let authError = AuthErrorCode(rawValue: error._code)
                {
                    self?.showLoginError(authError.description)
                }
                else
                {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let signupVC = segue.destination as? SignupVC
        {
            signupVC.delegate = delegate
        }
    }
}
