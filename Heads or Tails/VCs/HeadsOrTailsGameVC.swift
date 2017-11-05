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
    var gameManager: HeadsOrTailsGame? {
        didSet {
            guard let gameManager = gameManager else { return }
            
            firebaseManager.listen(on: gameManager.gameUID) { [weak self] (gameDetails) in
                self?.updateGameModel(with: gameDetails)
            }
        }
    }
    let notificationCenter = NotificationCenter.default
    let firebaseManager = FirebaseManager.instance
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        notificationCenter.addObserver(self, selector: #selector(updateWithGameDetails(_:)), name: .updateGameVCDetails, object: nil)
        notificationCenter.addObserver(self, selector: #selector(increaseRound(_:)), name: .increaseRound, object: nil)
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

            localHeadImageView.isUserInteractionEnabled = true
            localTailImageView.isUserInteractionEnabled = true
            
            // Check if bet has been made
            firebaseManager.getBet(forPlayerUID: localPlayer.uid, gameKey: gameUID, completion: { [weak self] (bet) in
                if bet == 0 {
                    self?.toggleBetRelatedViews(show: true)
                }
            })

        }
    }
    
    private func updateGameModel(with gameDetails: [String: Any]) {
        // Update status and round
        if let status = gameDetails["status"] as? String,
            let round = gameDetails["round"] as? Int {
            gameManager?.status = status
            gameManager?.round = round
        }
        
        // Update local players model
        if let localDetails = gameDetails[gameManager!.localPlayer.uid] as? [String: Any],
            let localBet = localDetails["bet"] as? Int {
            gameManager?.localBet = localBet
            
            if let localMoves = localDetails["move"] as? String {
                gameManager?.localMove = localMoves
            }
        }
        
        // Update opponent players model
        if let opponentDetails = gameDetails[gameManager!.opponentPlayer.uid] as? [String: Any],
            let opponentBet = opponentDetails["bet"] as? Int {
            gameManager?.opponentBet = opponentBet
            
            if let oppoenentMoves = opponentDetails["move"] as? String {
                gameManager?.opponentMove = oppoenentMoves
            }
        }
        
        statusLabel.text = gameManager?.getGameDescription()
    }
    
    @objc func increaseRound(_ notification: Notification) {
        guard let gameManager = gameManager else { return }
        guard let round = notification.userInfo?["round"] as? Int else { return }
        
        firebaseManager.updateRound(for: gameManager.gameUID, with: round)
        resetCoinsAlpha()
    }
    
    @objc func headImageViewSelected(_ sender: Any) {
        guard let gameManager = gameManager else { return }
        
        if !gameManager.localPlayerHasMoveForRound {
            toggleCoin(for: .heads)
            gameManager.addMove(.heads, for: gameManager.localPlayer)
        }
    }
    
    @objc func tailImageViewSelected(_ sender: Any) {
        guard let gameManager = gameManager else { return }
        
        if !gameManager.localPlayerHasMoveForRound {
            toggleCoin(for: .tails)
            gameManager.addMove(.tails, for: gameManager.localPlayer)
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
