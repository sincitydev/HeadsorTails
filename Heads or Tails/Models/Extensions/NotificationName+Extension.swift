//
//  NotificationName+Extension.swift
//  Heads or Tails
//
//  Created by Amanuel Ketebo on 9/4/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let authenticationDidChange = Notification.Name.init("authenticationDidChange")
    static let updateGameVCDetails = Notification.Name.init(rawValue: "updateGameVCDetails")
    static let gameDidUpdate = Notification.Name.init(rawValue: "gameDidUpdate")
}
