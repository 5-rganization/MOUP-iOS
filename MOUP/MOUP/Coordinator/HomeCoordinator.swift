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
        navigationController.pushViewController(vc, animated: true)
    }
    
    func moveToAttendanceHistory(navTitle: String) {
        let viewModel = AttendanceHistoryViewModel()
        let vc = AttendanceHistoryViewController(viewModel: viewModel, navTitle: navTitle)
        navigationController.pushViewController(vc, animated: true) // TODO: - 애니메이션 자연스러운지 다같이 확인해봐야함.
    }
    
}
