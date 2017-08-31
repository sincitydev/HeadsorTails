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
    func authenticationDidLogin()
    func authenticationDidLogout()
}

// TODO: Looks like theres a similar code between the loginVC and signupVC
//       Is there anyway can not repeat that same code in both VCs?

class LoginVC: UIViewController
{
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
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
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
                if let error = error, let authError = AuthErrorCode(rawValue: error._code)
                {
                    self?.showLoginError(authError.description)
                }
                else
                {
                    self?.delegate?.authenticationDidLogin()
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
        
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.errorMessageLabel.alpha = 1
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let signupVC = segue.destination as? SignupVC
        {
            signupVC.delegate = delegate
        }
    }
}
