//
//  HeadsOrTailsGameVC.swift
//  Heads or Tails
//
//  Created by Danny Pecoraro on 10/24/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//
import UIKit

class HeadsOrTailsGameVC: UIViewController {
    
    @IBOutlet weak var usersUsernameLabel: UILabel!
    
    @IBOutlet weak var usersCoinsLabel: UILabel!
    
    @IBOutlet weak var opponentsUsernameLabel: UILabel!
    
    @IBOutlet weak var opponentsCoinsLabel: UILabel!
    
    @IBOutlet weak var makeYourBetLabel: UILabel!
    
    @IBOutlet weak var bettingCoinsLabel: UILabel!
    
    @IBOutlet weak var bettingCoinImageView: UIImageView!
    
    @IBOutlet weak var uiBettingSliderOutlet: UISlider!
    
    @IBOutlet weak var waitingForChoicesView: UIView!
    
    var opponentPlayer = Player(uid: "skdbfwerbufwef", username: "The Joker", coins: 500, online: true)
    var user = Player(uid: "kweibvwernviwern", username: "DannyJP", coins: 2600, online: true)
    var usersBet = 0
    var usersTotal = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        
        
    }
    
    
    @IBAction func uiBettingSliderAction(_ sender: UISlider) {
        
        usersBet = Int(sender.value.rounded())
        bettingCoinsLabel.text = "\(usersBet)"
        let newTotal = user.coins - Int(sender.value.rounded())
        usersTotal = newTotal
        usersCoinsLabel.text = "\(usersTotal)"
        
    }
    
    func setUpView() {
        usersTotal = user.coins
        waitingForChoicesView.layer.borderWidth = 2
        
        usersUsernameLabel.text = "\(user.username)"
        usersCoinsLabel.text = "\(usersTotal)"
        uiBettingSliderOutlet.maximumValue = Float(user.coins)
        opponentsUsernameLabel.text = "\(opponentPlayer.username)"
        opponentsCoinsLabel.text = "\(opponentPlayer.coins)"
        
    }
    
    
    
}
