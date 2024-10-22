//
//  RootCoordinator.swift
//  CryptoCoins
//
//  Created by Sambit Prakash Dash on 21/10/24.
//

import Foundation
import UIKit

protocol RootCoordinatorProtocol: Coordinator {
    func moveToHome(animated: Bool)
}

extension RootCoordinatorProtocol {
    func moveToHome(animated: Bool) {
        HomeCoordinator(
            navigationController: self.navigationController,
            rootCoordinator: self
        )
        .start(animated: animated)
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
