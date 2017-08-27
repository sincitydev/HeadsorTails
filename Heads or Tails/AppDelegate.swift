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
class AppDelegate: UIResponder, UIApplicationDelegate
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
        
        if let user = Auth.auth().currentUser
        {
            // Nothing yet
        }
        else
        {
            let navVC = UIStoryboard.init(name: "Authentication", bundle: nil).instantiateInitialViewController() as! UINavigationController
            
            rootVC = navVC
        }
        
        window?.rootViewController = rootVC
    }
}

