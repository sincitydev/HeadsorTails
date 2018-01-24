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

class SignupVC: UIViewController, UITextFieldDelegate, AuthHelper {

    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    var validUsername = false
    fileprivate let firebaseManager = FirebaseManager.instance
    private let notificationCenter = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        usernameTextField.delegate = self
        errorMessageLabel.alpha = 0
    }
    
    @IBAction func signup() {
        let username = usernameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        if validInput(username: username, email: email, password: password, validUsername: validUsername) {
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] (user, error) in
                
                if let error = error, let authError = AuthErrorCode(rawValue: error._code) {
                    self?.showLoginError(self?.errorMessageLabel, with: authError.description)
                }
                else {
                    guard let user = user else { return }
                    
                    let player = Player(uid: user.uid, username: username, coins: 100, online: true)
                    
                    self?.firebaseManager.saveNewUser(player)
                    self?.notificationCenter.post(name: .authenticationDidChange, object: nil)
                    
                }
            }
        }
        else {
            if validUsername == false {
                showLoginError(self.errorMessageLabel, with: "Username already in use")
            }
            else {
                showLoginError(self.errorMessageLabel, with: "Invalid input")
            }
        }
    }
    
    deinit {
        print("SignupVC has been deallocated :)")
    }
}

extension SignupVC: UITextViewDelegate {
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        firebaseManager.checkUsername(usernameTextField.text ?? "") { [weak self] (authUsernameError) in
            if let authUsernameError = authUsernameError {
                self?.validUsername = false
                self?.showLoginError(self?.errorMessageLabel, with: authUsernameError.description)
            }
            else {
                self?.validUsername = true
                self?.hideLoginError(self?.errorMessageLabel)
            }
        }
    }
}
