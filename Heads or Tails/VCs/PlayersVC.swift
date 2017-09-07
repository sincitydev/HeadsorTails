//
//  PlayersVC.swift
//  Heads or Tails
//
//  Created by Amanuel Ketebo on 8/29/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit
import FirebaseAuth

class PlayersVC: UIViewController
{
    @IBOutlet weak var playersTableView: UITableView!
    
    fileprivate var players: [Player] = []
    private var firebaseManager = FirebaseManager()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        playersTableView.dataSource = self
        fetchPlayers()
    }
    
    private func fetchPlayers()
    {
        firebaseManager.fetchPlayers { [weak self] (players, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            else if let players = players
            {
                self?.players = players
                self?.playersTableView.reloadData()
            }
        }
    }
    
    @IBAction func touchedLogout(_ sender: UIBarButtonItem)
    {
        let logoutVC = LogoutVC()
        
        present(logoutVC, animated: true, completion: nil)
    }
}

extension PlayersVC: UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIStoryboard.playerCell, for: indexPath) as! PlayerCell
        let player = players[indexPath.row]
        
        cell.usernameLabel.text = player.username
        cell.coins.text = "\(player.coins)" 
        
        
        return cell
    }
}
