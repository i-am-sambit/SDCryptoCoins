//
//  TableViewCell+Extension.swift
//  CryptoCoins
//
//  Created by Sambit Prakash Dash on 22/10/24.
//

import Foundation
import UIKit

extension UITableViewCell {
    static var reuseIdentifier: String {
        let file = NSStringFromClass(Self.self)
        return file.components(separatedBy: ".").first!
    }
}
