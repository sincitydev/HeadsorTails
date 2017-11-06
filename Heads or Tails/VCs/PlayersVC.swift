//
//  PlayersVC.swift
//  Heads or Tails
//
//  Created by Amanuel Ketebo on 8/29/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit
import FirebaseAuth

class PlayersVC: UIViewController {
    @IBOutlet weak var playersTableView: UITableView!
    @IBOutlet weak var viewAllPlayersSwitch: UISwitch!
    
    fileprivate var players: [Player] = []
    fileprivate var opponentPlayerUIDs: [String] = []
    fileprivate var firebaseManager = FirebaseManager.instance
    fileprivate var notificationCenter = NotificationCenter.default
    
    fileprivate var playerCellHeight: CGFloat = 75
    fileprivate var emptyPlayerCellHeight: CGFloat = 380
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playersTableView.dataSource = self
        playersTableView.delegate = self
        setupViews()
        refreshPlayers()
    }
    @IBAction func viewAllPlayersSwitch(_ sender: UISwitch) {
        refreshPlayers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        firebaseManager.postOnlineStatus(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshPlayers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        firebaseManager.postOnlineStatus(false)
    }
    
    // example of finding a game and updating a players bet
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        firebaseManager.getGameKeyWith(playerUID: (Auth.auth().currentUser?.uid)!, playerUId: "opponentsUID") { (gameKey) in
//            if gameKey != nil {
//                self.firebaseManager.updateBet(forPlayerUID: "opponentsUID", gameKey: gameKey!, bet: 1000)
//            }
//        }
//    }
    
    private func setupViews() {
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action: #selector(refreshPlayers), for: .valueChanged)
        playersTableView.refreshControl = refreshControl
        playersTableView.delegate = self
        playersTableView.dataSource = self
    }
    
//    private func fetchPlayers()
//    {
//        playersTableView.refreshControl?.beginRefreshing()
//        firebaseManager.fetchPlayers { [weak self] (players, error) in
//            self?.playersTableView.refreshControl?.endRefreshing()
//            if let error = error {
//                print(error.localizedDescription)
//            }
//            else if let players = players
//            {
//                self?.players = players
//                self?.playersTableView.reloadData()
//            }
//        }
//    }
    
    @IBAction func searchUsersAction(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "SearchUsersVC", sender: self)
    }
    
    @objc private func refreshPlayers() {
        firebaseManager.getPlayers { [weak self] (returnedPlayers) in
            guard let strongSelf = self else { return }
            
            var fetchedPlayers: [Player] = []
            
            strongSelf.navigationItem.title = strongSelf.viewAllPlayersSwitch.isOn ? "Online Players" : "All Players"
            
            returnedPlayers.forEach({ (player) in
                if strongSelf.viewAllPlayersSwitch.isOn {
                    if player.online == true {
                        fetchedPlayers.append(player)
                    }
                } else {
                    fetchedPlayers.append(player)
                }
            })
            
            strongSelf.players = fetchedPlayers
            
            strongSelf.firebaseManager.getOpponentsFor(currentPlayerUID: Auth.auth().currentUser!.uid, completion: { (opponentPlayerUIDs) in
                
                strongSelf.opponentPlayerUIDs = opponentPlayerUIDs
                strongSelf.playersTableView.reloadData()
                strongSelf.playersTableView.refreshControl?.endRefreshing()
            })
        }
    }
    
    @IBAction func touchedLogout(_ sender: UIBarButtonItem) {
        let message = "Are you sure \n you want to logout?"
        let leftButtonData = ButtonData(title: "Yes", color: .red) { [weak self] in
            self?.firebaseManager.logout { _ in }
        }
        let rightButtonData = ButtonData(title: "Cancel", color: .black, action: nil)
        let informationVC = InformationVC(message: message, image: UIImage(named: "bye"), leftButtonData: leftButtonData, rightButtonData: rightButtonData)
        
        present(informationVC, animated: true, completion: nil)
    }
    
    deinit {
        print("PlayersVC has been deallocated :)")
    }
}

extension PlayersVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if players.count == 0 && section == 1 {
            return 1
        }
        else if section == 0 {
            return players.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: PlayerCell.identifier, for: indexPath) as! PlayerCell
            let player = players[indexPath.row]
            
            cell.usernameLabel.text = player.username
            cell.coins.text = String(player.coins)
            cell.onlineView.backgroundColor = players[indexPath.row].online ? #colorLiteral(red: 0.3411764706, green: 0.6235294118, blue: 0.168627451, alpha: 1) : .clear
            cell.inGameView.isHidden = opponentPlayerUIDs.contains(player.uid) ? false : true
            
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: EmptyPlayerCell.identifier, for: indexPath) as! EmptyPlayerCell
        
            return cell
        }
    }
}

extension PlayersVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? playerCellHeight : emptyPlayerCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        playersTableView.deselectRow(at: indexPath, animated: true)
        
        firebaseManager.getGameKeyWith(playerUID: firebaseManager.uid, playerUID: players[indexPath.row].uid) { [weak self] (gameKey) in
            guard let strongSelf = self else { return }
            
            if gameKey == nil {
                // Create game key
        
                let opponentUsername = strongSelf.players[indexPath.row].username
                let leftButtonData = ButtonData(title: "Yes", color: Palette.blue, action: {
                    let gameKey = strongSelf.firebaseManager.createGame(oppenentUID: strongSelf.players[indexPath.row].uid, initialBet: 0)
                    strongSelf.firebaseManager.getPlayerInfoFor(uid: strongSelf.firebaseManager.uid, completion: { (localPlayer) in
                        let dict = ["localPlayer" : localPlayer, "opponentPlayer" : strongSelf.players[indexPath.row], "gameKey" : gameKey] as [String: Any]
                        
                        strongSelf.notificationCenter.post(name: .updateGameVCDetails, object: nil, userInfo: dict)
                    })
                    strongSelf.opponentPlayerUIDs.append(strongSelf.players[indexPath.row].uid)
                    strongSelf.opponentPlayerUIDs.append(strongSelf.players[indexPath.row].uid)
                    strongSelf.playersTableView.reloadData()
                    strongSelf.performSegue(withIdentifier: UIStoryboard.gameVCSegue, sender: nil)
                })
                let rightButtonData = ButtonData(title: "No", color: .red, action: nil)
                let modalPopup = InformationVC(message: "Are you sure you would like to create a game with \(opponentUsername)", image: #imageLiteral(resourceName: "flipping"), leftButtonData: leftButtonData, rightButtonData: rightButtonData)
            
                strongSelf.present(modalPopup, animated: true, completion: nil)
            
                
            } else {
                strongSelf.firebaseManager.getPlayerInfoFor(uid: strongSelf.firebaseManager.uid, completion: { (localPlayer) in
                    let dict = ["localPlayer" : localPlayer, "opponentPlayer" : strongSelf.players[indexPath.row], "gameKey" : gameKey!] as [String: Any]
                    
                    strongSelf.notificationCenter.post(name: .updateGameVCDetails, object: nil, userInfo: dict)
                })
                
                strongSelf.performSegue(withIdentifier: UIStoryboard.gameVCSegue, sender: nil)
            }
        }
    }
}
