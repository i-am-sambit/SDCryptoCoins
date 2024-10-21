//
//  HomeCoordinator.swift
//  CryptoCoins
//
//  Created by Sambit Prakash Dash on 21/10/24.
//

import Foundation
import UIKit

final class HomeCoordinator: Coordinator {
    var navigationController: UINavigationController
    weak var rootCoordinator: RootCoordinatorProtocol?
    
    init(navigationController: UINavigationController, rootCoordinator: RootCoordinatorProtocol?) {
        self.navigationController = navigationController
        self.rootCoordinator = rootCoordinator
    }
    
    func start(animated: Bool) {
        let controller = HomeViewController()
        navigationController.pushViewController(controller, animated: animated)
    }
}
