//
//  View+Extension.swift
//  CryptoCoins
//
//  Created by Sambit Prakash Dash on 23/10/24.
//

import Foundation
import UIKit

enum ShadowState {
    case shadow(color: UIColor, opacity: Float, offset: CGSize, radius: CGFloat)
    case remove
}

extension UIView {
    func apply(shadow state: ShadowState) {
        switch state {
            case let .shadow(color, opacity, offset, radius):
                self.layer.shadowColor = color.cgColor
                self.layer.shadowOpacity = opacity
                self.layer.shadowOffset = offset
                self.layer.shadowRadius = radius
            case .remove:
                self.layer.shadowColor = UIColor.clear.cgColor
                self.layer.shadowOpacity = 0
                self.layer.shadowOffset = .zero
                self.layer.shadowRadius = 0
        }
        self.layer.masksToBounds = false
    }
}
