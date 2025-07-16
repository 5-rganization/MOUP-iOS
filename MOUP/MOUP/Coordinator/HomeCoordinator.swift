//
//  homeCoordinator.swift
//  MOUP
//
//  Created by 양원식 on 7/14/25.
//
import UIKit

final class HomeCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let homeVM = HomeViewModel()
        let homeVC = HomeViewController(
            coordinator: self,
            homeViewModel: homeVM
        )
        navigationController.pushViewController(homeVC, animated: false)
    }
}
