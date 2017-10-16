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

class SignupVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private let firebaseManager = FirebaseManager.shared
    private let notificationCenter = NotificationCenter.default
    private let FBManager = FirebaseManagerV2.instance
    
    var validInput: Bool {
        let username = usernameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        if email.isEmpty || password.isEmpty || username.isEmpty {
            return false
        }
        else {
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        usernameTextField.delegate = self
    }
    
    private func setupViews() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        errorMessageLabel.alpha = 0
    }
    
    @IBAction func signup() {
        let username = usernameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        if validInput {
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] (user, error) in
                
                if let error = error, let authError = AuthErrorCode(rawValue: error._code) {
                    self?.showLoginError(authError.description)
                }
                else {
                    guard let user = user else { return }
                    
                    let player = Player(uid: user.uid, username: username, coins: 100)
                    
                    //self?.firebaseManager.saveNewPlayer(player)
                    self?.FBManager.saveNewUser(player)
                    self?.notificationCenter.post(name: .authenticationDidChange, object: nil)
                    
                }
            }
        }
        else {
            showLoginError("Invalid input")
        }
    }
    
    private func showLoginError(_ message: String) {
        errorMessageLabel.text = message
        errorMessageLabel.fadeIn(duration: 0.2)
    }
    
    private func hideLoginError() {
        errorMessageLabel.text = ""
        errorMessageLabel.fadeOut(duration: 0.2)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        firebaseManager.checkUsername(usernameTextField.text ?? "") { [weak self] (authUsernameError) in
            if let authUsernameError = authUsernameError {
                self?.showLoginError(authUsernameError.description)
            }
            else {
                self?.hideLoginError()
            }
        }
    }
}
