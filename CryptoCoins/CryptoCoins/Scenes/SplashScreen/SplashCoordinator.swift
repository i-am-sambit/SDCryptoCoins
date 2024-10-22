//
//  SplashCoordinator.swift
//  CryptoCoins
//
//  Created by Sambit Prakash Dash on 21/10/24.
//

import Foundation
import UIKit

final class SplashCoordinator: Coordinator {
    var navigationController: UINavigationController
    var rootCoordinator: RootCoordinatorProtocol
    
    init(navigationController: UINavigationController, rootCoordinator: RootCoordinatorProtocol) {
        self.navigationController = navigationController
        self.rootCoordinator = rootCoordinator
    }
    
    func start(animated: Bool) {
        let controller = SplashViewController()
        controller.coordinator = self
        navigationController.pushViewController(controller, animated: animated)
    }
    
    func navigateToHome() {
        rootCoordinator.moveToHome(animated: false)
    }
}
