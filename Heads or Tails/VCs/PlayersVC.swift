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
    
    @objc private func refreshPlayers() {
        FBmanager.getPlayers { (returnedPlayers) in
            self.players = returnedPlayers
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
