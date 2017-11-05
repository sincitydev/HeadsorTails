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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        notificationCenter.removeObserver(self)
    }
    
    // MARK: - Methods
    private func setupViews() {
        UIView.hide(views: bettingCoinsLabel, bettingSlider, confirmBetButton, bettingCoinImageView)
        
        localHeadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(headImageViewSelected(_:))))
        localTailImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tailImageViewSelected(_:))))
        
        localHeadImageView.isUserInteractionEnabled = false
        localTailImageView.isUserInteractionEnabled = false
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
            gameManager!.gameUID = gameUID

            localTailImageView.isUserInteractionEnabled = true
            localTailImageView.isUserInteractionEnabled = true
            
            // Check if bet has been made
            firebaseManager.getBet(forPlayerUID: localPlayer.uid, gameKey: gameUID, completion: { [weak self] (bet) in
                if bet == 0 {
                    self?.toggleBetRelatedViews(hide: false)
                }
            })

        }
    }
    
    @objc func headImageViewSelected(_ sender: Any) {
        toggleAlpha(for: .heads)
        gameManager?.addMove(.heads, for: gameManager!.localPlayer)
    }
    
    @objc func tailImageViewSelected(_ sender: Any) {
        toggleAlpha(for: .tails)
        gameManager?.addMove(.tails, for: gameManager!.localPlayer)
    }
    
    // MARK: - IBActions
    @IBAction func bettingSliderChanged(_ sender: UISlider) {
        let betAmount = Int(sender.value.rounded())
        if gameManager != nil {
            let coinsAfterBet = gameManager!.localPlayer.coins - betAmount
            
            bettingCoinsLabel.text = String(betAmount)
            localCoinsLabel.text = "\(coinsAfterBet)"
        }
    }
    
    @IBAction func confirmBetButtonPressed(_ sender: Any) {
        guard let bet = Int(bettingCoinsLabel.text!) else { return }
        if gameManager != nil {
            firebaseManager.updateBet(forPlayerUID: gameManager!.localPlayer.uid, gameKey: gameManager!.gameUID, bet: bet)
            toggleBetRelatedViews(hide: true)
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helper methods
    private func addObservers() {
        notificationCenter.addObserver(self, selector: #selector(updateWithGameDetails(_:)), name: .updateGameVCDetails, object: nil)
    }
    
    private func toggleBetRelatedViews(hide: Bool) {
        if hide {
            UIView.hide(views: bettingCoinsLabel, bettingSlider, confirmBetButton, bettingCoinImageView)
        } else {
            UIView.show(views: bettingCoinsLabel, bettingSlider, confirmBetButton, bettingCoinImageView)
        }
    }
    
    private func toggleAlpha(for move: Move) {
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
}
