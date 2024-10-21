//
//  RootCoordinator.swift
//  CryptoCoins
//
//  Created by Sambit Prakash Dash on 21/10/24.
//

import Foundation
import UIKit

protocol RootCoordinatorProtocol: Coordinator {
    func moveToHome()
}

extension RootCoordinatorProtocol {
    func moveToHome() {
        HomeCoordinator(
            navigationController: self.navigationController,
            rootCoordinator: self
        )
        .start(animated: true)
    }
}

final class RootCoordinator: RootCoordinatorProtocol {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start(animated: Bool) {
        SplashCoordinator(
            navigationController: navigationController,
            rootCoordinator: self
        )
        .start(animated: animated)
    }
}
