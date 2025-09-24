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

    func moveToRegisterWorkplace() {
        let coordinator = WorkplaceRegisterCoordinator(navigationController: self.navigationController)
        childCoordinators.append(coordinator)
        DispatchQueue.main.async {
            coordinator.start()
        }
    }
    
    func moveToManageAttendance() {
        let viewModel = ManageAttendanceViewModel()
        let vc = ManageAttendanceViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: false)
    }
}
