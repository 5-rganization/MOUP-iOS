//
//  AppCoordinator.swift
//  MOUP
//
//  Created by 양원식 on 7/14/25.
//

import UIKit

final class AppCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let tabBarCoordinator = TabBarCoordinator(window: window)
        childCoordinators.append(tabBarCoordinator)
        tabBarCoordinator.start()
    }
}

