//
//  Coordinator.swift
//  CryptoCoins
//
//  Created by Sambit Prakash Dash on 21/10/24.
//

import Foundation
import UIKit

protocol Coordinator: AnyObject {
    
    /// The navigation controller for coordinator
    var navigationController: UINavigationController { get set }
    
    /// The coordinator takes control and activate himself.
    ///
    /// - Parameters:
    ///   - animated: Set the value to true to animate the transition. Pass false if you are setting up a navigation controller before its view is displayed.
    func start(animated: Bool)
    
    /// Pops the top view controller from the navigation stack and updates the display.
    ///
    /// - Parameters:
    ///   - animated: Set this value to true to animate the transition.
    func popViewController(animated: Bool)
}

extension Coordinator {
    func popViewController(animated: Bool) {
        navigationController.popViewController(animated: animated)
    }
}
