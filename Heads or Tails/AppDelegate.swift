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
class AppDelegate: UIResponder, UIApplicationDelegate {   
    var window: UIWindow?
    let notificationCenter = NotificationCenter.default
    let firebaseManager = FirebaseManager.instance

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        notificationCenter.addObserver(self, selector: #selector(setupRootVC), name: .authenticationDidChange, object: nil)
        setAppearance()
        setupRootVC()
        
        return true
    }
    
    private func setAppearance() {
        let appNavigationBar = UINavigationBar.appearance()
        
        appNavigationBar.barStyle = .black
        appNavigationBar.tintColor = Palette.white
        appNavigationBar.barTintColor = Palette.blue
    }
    
    @objc private func setupRootVC() {
        var rootVC: UIViewController!
        
        if let _ = Auth.auth().currentUser {
            let navVC = UIStoryboard.main.instantiateInitialViewController() as! UINavigationController

            rootVC = navVC
        }
        else {
            let navVC = UIStoryboard.auth.instantiateInitialViewController() as! UINavigationController
            
            rootVC = navVC
        }
        
        window?.rootViewController = rootVC
    }
}

