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

class LoginVC: UIViewController, AuthHelper {
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private var firebaseManager = FirebaseManager()
    private let notificationCenter = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {        
        errorMessageLabel.alpha = 0
    }
    
    @IBAction func login() {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        if validInput(email: email, password: password) {
            firebaseManager.login(email: email, password: password) { [weak self] (user, error) in
                if let error = error, let authError = AuthErrorCode(rawValue: error._code) {
                    self?.showLoginError(self?.errorMessageLabel, with: authError.description)
                }
                else {
                    self?.notificationCenter.post(name: .authenticationDidChange, object: nil)
                }
            }
        }
        else {
            self.showLoginError(errorMessageLabel, with: "Invalid input")
        }
    }
    
    deinit {
        print("LoginVC has been deallocated :)")
    }
}
