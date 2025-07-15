//
//  MyPageCoordinator.swift
//  MOUP
//
//  Created by 양원식 on 7/14/25.
//

import UIKit

final class MyPageCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let myPageVC = MyPageViewController()
        navigationController.pushViewController(myPageVC, animated: false)
    }
}
