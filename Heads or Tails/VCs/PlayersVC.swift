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
    fileprivate var playerCellHeight: CGFloat = 75
    fileprivate var emptyPlayerCellHeight: CGFloat = 380
    private var firebaseManager = FirebaseManager()
    private var FBmanager = FirebaseManagerV2()
    
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
        FBmanager.postOnlineStatus(onlineStatus: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        FBmanager.postOnlineStatus(onlineStatus: false)
    }
    
    // example of finding a game and updating a players bet
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        FBmanager.getGameKeyWith(playerUID: (Auth.auth().currentUser?.uid)!, playerUId: "opponentsUID") { (gameKey) in
//            if gameKey != nil {
//                self.FBmanager.updateBet(forPlayerUID: "opponentsUID", gameKey: gameKey!, bet: 1000)
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
    
    @IBAction func searchUsersAction(_ sender: Any) {
        performSegue(withIdentifier: "SearchUsersVC", sender: self)
    }
    
    @objc private func refreshPlayers()
    {
        FBmanager.getPlayers { (returnedPlayers) in
            self.players = []
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
            
            if player.online == true {
                let onlineView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 10, height: cell.bounds.height)))
                onlineView.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                cell.addSubview(onlineView)
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
}
