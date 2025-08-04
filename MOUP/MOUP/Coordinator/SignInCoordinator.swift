//
//  LoginCoordinator.swift
//  MOUP
//
//  Created by 송규섭 on 7/26/25.
//

import UIKit

final class SignInCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let signInViewController = SignInViewController()

        let nav = UINavigationController(rootViewController: signInViewController)
        window.rootViewController = signInViewController
        window.makeKeyAndVisible()
    }
}
