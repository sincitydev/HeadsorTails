//
//  HeadsOrTailsGameVC.swift
//  Heads or Tails
//
//  Created by Danny Pecoraro on 10/24/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//
import UIKit

class HeadsOrTailsGameVC: UIViewController {
    // MARK: - IBOutlets
    // Local's IBOutlets
    @IBOutlet weak var localUsernameLabel: UILabel!
    @IBOutlet weak var localCoinsLabel: UILabel!
    @IBOutlet weak var localHeadImageView: UIImageView!
    @IBOutlet weak var localTailImageView: UIImageView!
    
    // Opponent's IBOutlets
    @IBOutlet weak var opponentUsernameLabel: UILabel!
    @IBOutlet weak var opponentCoinsLabel: UILabel!
    @IBOutlet weak var opponentHeadImageView: UIImageView!
    @IBOutlet weak var opponentTailImageView: UIImageView!
    
    // Betting IBOutlets
    @IBOutlet weak var bettingCoinsLabel: UILabel!
    @IBOutlet weak var bettingCoinImageView: UIImageView!
    @IBOutlet weak var bettingSlider: UISlider!
    @IBOutlet weak var confirmBetButton: UIButton!
    
    // Middle status IBOutlets
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: - Properties
    var gameManager: HeadsOrTailsGame?
    let notificationCenter = NotificationCenter.default
    let firebaseManager = FirebaseManager.instance
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        notificationCenter.addObserver(self, selector: #selector(updateWithGameDetails(_:)), name: .updateGameVCDetails, object: nil)
        notificationCenter.addObserver(self, selector: #selector(gameDidUpdate(_:)), name: .gameDidUpdate, object: nil)
    }
    
    // MARK: - Methods
    private func setupViews() {
        UIView.hide(views: bettingCoinsLabel, bettingSlider, confirmBetButton, bettingCoinImageView)
        
        localHeadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(headImageViewSelected(_:))))
        localTailImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tailImageViewSelected(_:))))
        
        localHeadImageView.isUserInteractionEnabled = true
        localTailImageView.isUserInteractionEnabled = true
    }
    
    @objc func gameDidUpdate(_ notication: Notification) {
        statusLabel.text = gameManager!.getGameDescription()
        if gameManager!.localMove.count < gameManager!.round {
            if gameManager!.localMove.count != 5 {
                resetCoinsAlpha()
            }
        }
        
        // opponent makes a move first
        if gameManager!.opponentMove.count > 0 {
            let move = gameManager!.opponentMove.last!
            switch move {
                case "H":
                    self.opponentHeadImageView.alpha = 1
                    self.opponentTailImageView.alpha = 0.1
                case "T":
                    self.opponentHeadImageView.alpha = 0.1
                    self.opponentTailImageView.alpha = 1
                default:
                    break
            }
        }
        
        if gameManager!.getGameDescription() == "Waiting on opponent to move" {
            self.opponentHeadImageView.alpha = 1
            self.opponentTailImageView.alpha = 1
        }
    }
    
    @objc func updateWithGameDetails(_ notification: Notification) {
        if let info = notification.userInfo as? [String : Any],
            let localPlayer = info["localPlayer"] as? Player,
            let opponentPlayer = info["opponentPlayer"] as? Player,
            let gameUID = info["gameKey"] as? String {

            // Update view with game details
            localUsernameLabel.text = localPlayer.username
            localCoinsLabel.text = String(localPlayer.coins)
            opponentUsernameLabel.text = opponentPlayer.username
            opponentCoinsLabel.text = String(opponentPlayer.coins)
            bettingSlider.maximumValue = Float(localPlayer.coins)
            
            // Update game model
            gameManager = HeadsOrTailsGame(gameID: gameUID, localPlayer: localPlayer, opponent: opponentPlayer)
      
            // Check if bet has been made
            firebaseManager.getBet(forPlayerUID: localPlayer.uid, gameKey: gameUID, completion: { [weak self] (bet) in
                if bet == 0 {
                    self?.toggleBetRelatedViews(show: true)
                    self?.localHeadImageView.isUserInteractionEnabled = false
                    self?.localTailImageView.isUserInteractionEnabled = false
                }
            })

        }
    }
    
    @objc func headImageViewSelected(_ sender: Any) {
        if gameManager != nil {
            if gameManager!.localMove.count < gameManager!.round {
                if gameManager!.round != 6 {
                    toggleCoin(for: .heads)
                    gameManager!.addMove(.heads, for: gameManager!.localPlayer)
                }
            }
        }
    }
    
    @objc func tailImageViewSelected(_ sender: Any) {
        if gameManager != nil {
            if gameManager!.localMove.count < gameManager!.round {
                if gameManager!.round != 6{
                    toggleCoin(for: .tails)
                    gameManager!.addMove(.tails, for: gameManager!.localPlayer)
                }
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction func bettingSliderChanged(_ sender: UISlider) {
        guard let _ = gameManager else { return }
        
        let betAmount = Int(sender.value.rounded())
        let coinsAfterBet = gameManager!.localPlayer.coins - betAmount
            
        bettingCoinsLabel.text = String(betAmount)
        localCoinsLabel.text = "\(coinsAfterBet)"
    }
    
    @IBAction func confirmBetButtonPressed(_ sender: Any) {
        guard let bet = Int(bettingCoinsLabel.text!) else { return }
        guard bet > 0 else { return }
        guard let gameManager = gameManager else { return }
        
        firebaseManager.updateBet(forPlayerUID: gameManager.localPlayer.uid, gameKey: gameManager.gameUID, bet: bet)
        toggleBetRelatedViews(show: false)
        
        localHeadImageView.isUserInteractionEnabled = true
        localTailImageView.isUserInteractionEnabled = true
    }
   
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helper methods
    private func toggleCoin(for move: Move) {
        let selectedAlpha: CGFloat = 1
        let unselectedAlpha: CGFloat = 0.1
        
        switch move {
            case .heads:
                localHeadImageView.alpha = selectedAlpha
                localTailImageView.alpha = unselectedAlpha
            case .tails:
                localHeadImageView.alpha = unselectedAlpha
                localTailImageView.alpha = selectedAlpha
        }
    }
    
    private func toggleBothCoins(show: Bool) {
        if show {
            UIView.show(views: localHeadImageView, localTailImageView)
        } else {
            UIView.hide(views: localHeadImageView, localTailImageView)
        }
    }
    
    private func toggleBetRelatedViews(show: Bool) {
        if show {
            UIView.show(views: bettingCoinsLabel, bettingSlider, confirmBetButton, bettingCoinImageView)
        } else {
            UIView.hide(views: bettingCoinsLabel, bettingSlider, confirmBetButton, bettingCoinImageView)
        }
    }
    
    private func resetCoinsAlpha() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            sleep(1)
            
            DispatchQueue.main.async {
                self?.localHeadImageView.alpha = 1
                self?.localTailImageView.alpha = 1
            }
        }
    }
}
