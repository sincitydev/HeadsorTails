//
//  SearchUserVC.swift
//  Heads or Tails
//
//  Created by Danny Pecoraro on 10/16/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit
import Firebase

class SearchUserVC: UIViewController {

    @IBOutlet weak var userSearchTextField: UITextField!

    @IBOutlet weak var tableview: UITableView!

    var returnedUsers = [Player]()
    var usersSearched = [Player]()

    var firebaseManager = FirebaseManager.instance


    override func viewDidLoad() {
        super.viewDidLoad()
        userSearchTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        firebaseManager.getPlayers { (returnedPlayers) in
            self.returnedUsers = returnedPlayers
            self.usersSearched = returnedPlayers
            self.tableview.reloadData()
        }
    }

  @objc func textFieldDidChange() {
        if userSearchTextField.text == "" {
            usersSearched = returnedUsers
            tableview.reloadData()
        } else {
            usersSearched = []
            returnedUsers.forEach({ (player) in
                if player.username.lowercased().contains(userSearchTextField.text!.lowercased()) {
                    usersSearched.append(player)
                }
            })
            tableview.reloadData()
        }
    }



    @IBAction func backButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension SearchUserVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersSearched.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableview.dequeueReusableCell(withIdentifier: "searchPlayerCell") as? PlayerCell else { return UITableViewCell() }
        let user = usersSearched[indexPath.row]
        cell.usernameLabel.text = user.username
        cell.coins.text = String(user.coins)
        if user.online {
            cell.onlineView.backgroundColor = #colorLiteral(red: 0, green: 0.5603182912, blue: 0, alpha: 1)
        } else {
            cell.onlineView.backgroundColor = UIColor.clear
        }
        return cell
    }
}

