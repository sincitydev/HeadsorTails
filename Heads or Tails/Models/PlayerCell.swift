//
//  PlayerCell.swift
//  Heads or Tails
//
//  Created by Amanuel Ketebo on 9/6/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import UIKit

class PlayerCell: UITableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var coins: UILabel!
    @IBOutlet weak var onlineView: UIView!
    @IBOutlet weak var inGameView: UIView!
    
    static let identifier = "playerCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
