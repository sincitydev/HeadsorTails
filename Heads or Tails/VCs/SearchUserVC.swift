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
    
    var usersSearched = [Player]()
    
    var firebaseManager = FirebaseManager.instance
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userSearchTextField.delegate = self
        userSearchTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        // Do any additional setup after loading the view.
    }

  @objc func textFieldDidChange() {
        
        if userSearchTextField.text == "" {
            usersSearched = []
            tableview.reloadData()
        } else {
            firebaseManager.searchPlayers(searchQuery: userSearchTextField.text!, completion: { (players) in
                self.usersSearched = players
                self.tableview.reloadData()
            })
        }
        
    }



    @IBAction func backButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension SearchUserVC: UITextFieldDelegate {
    
    
    
}

extension SearchUserVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersSearched.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableview.dequeueReusableCell(withIdentifier: "cell") else { return UITableViewCell() }
        let user = usersSearched[indexPath.row]
        cell.textLabel?.text = user.username
        return cell
    }
    
    
}

