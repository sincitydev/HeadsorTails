//
//  AppDelegate.swift
//  Heads or Tails
//
//  Created by Amanuel Ketebo on 8/24/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AuthenticationDelegate
{   
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        FirebaseApp.configure()
        setupRootVC()
        
        return true
    }
    
    private func setupRootVC()
    {
        var rootVC: UIViewController!
        
        if let _ = Auth.auth().currentUser
        {
            let navVC = UIStoryboard.main.instantiateInitialViewController() as! UINavigationController
            let playerVC = navVC.viewControllers.first as! PlayersVC
            
            playerVC.delegate = self
            rootVC = navVC
        }
        else
        {
            let navVC = UIStoryboard.auth.instantiateInitialViewController() as! UINavigationController
            let loginVC = navVC.viewControllers.first as! LoginVC
            
            loginVC.delegate = self
            rootVC = navVC
        }
        
        window?.rootViewController = rootVC
    }
    
    // AuthenticationDelegate methods
    func authenticationDidLogin()
    {
        setupRootVC()
    }
    
    func authenticationDidLogout()
    {
        setupRootVC()
    }
}

