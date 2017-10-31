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
        firebaseManager.getPlayers { (returnedPlayers) in
            self.players = []
            
            if self.viewAllPlayersSwitch.isOn {
                self.navigationItem.title = "Online Players"
            } else {
                self.navigationItem.title = "All Players"
            }
            
            returnedPlayers.forEach({ (player) in
                if self.viewAllPlayersSwitch.isOn {
                    if player.online == true {
                        self.players.append(player)
                    }
                } else {
                    self.players.append(player)
                }
            })
            
            self.playersTableView.reloadData()
            self.playersTableView.refreshControl?.endRefreshing()
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
            
            if players[indexPath.row].online == true {
                cell.onlineView.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            } else {
                cell.onlineView.backgroundColor = UIColor.clear
            }
            cell.usernameLabel.text = player.username
            cell.coins.text = String(player.coins)
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: EmptyPlayerCell.identifier, for: indexPath) as! EmptyPlayerCell
        
            return cell
        }
    }
}

extension PlayersVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return playerCellHeight
        }
        else {
            return emptyPlayerCellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        playersTableView.deselectRow(at: indexPath, animated: true)
        firebaseManager.getGameKeyWith(playerUID: (Auth.auth().currentUser?.uid)!, playerUId: players[indexPath.row].uid) { [weak self] (gameKey) in
            if gameKey == nil {
                // Create game key
                let gameKey = self?.firebaseManager.createGame(oppenentUID: (self?.players[indexPath.row].uid)!, initialBet: 0)
                self?.firebaseManager.getPlayerInfoFor(uid: (Auth.auth().currentUser?.uid)!, completion: { (localPlayer) in
                    let dict = ["localPlayer" : localPlayer as Any, "opponentPlayer" : self?.players[indexPath.row] as Any, "gameKey" : gameKey! as Any] as [String: Any]
                
                    self?.notificationCenter.post(name: NSNotification.Name.init(rawValue: "Update GameVC Details"), object: nil, userInfo: dict)
                })
            } else {
           
                self?.firebaseManager.getPlayerInfoFor(uid: (Auth.auth().currentUser?.uid)!, completion: { (localPlayer) in
                    let dict = ["localPlayer" : localPlayer as Any, "opponentPlayer" : self?.players[indexPath.row] as Any, "gameKey" : gameKey! as Any] as [String: Any]
                    self?.notificationCenter.post(name: NSNotification.Name.init(rawValue: "Update GameVC Details"), object: nil, userInfo: dict)
                })
            }
            self?.performSegue(withIdentifier: "gameVCSegue", sender: nil)
        }
    }
}
