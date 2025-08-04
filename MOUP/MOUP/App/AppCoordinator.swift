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
    var isSignedIn = false // TODO: - 실제 로그인 여부를 알 수 있도록 변경

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        if isSignedIn {
            let tabBarCoordinator = TabBarCoordinator(window: window)
            childCoordinators.append(tabBarCoordinator)
            tabBarCoordinator.start()
        } else {
            let signInCoordinator = SignInCoordinator(window: window)
            childCoordinators.append(signInCoordinator)
            signInCoordinator.start()
        }
    }
}

