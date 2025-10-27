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
    
    func presentWorkplaceRegistrationSheet() {
        let coordinator = WorkplaceRegisterSheetCoordinator(navigationController: navigationController)
        coordinator.coordinator = self
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    
    func moveToAllRoutine() {
        let viewModel = AllRoutineViewModel()
        let vc = AllRoutineViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func moveToTodayRoutine() {
        let viewModel = TodayRoutineViewModel()
        let vc = TodayRoutineViewController(viewModel: viewModel)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func moveToWorkplaceRoutineList(with todayRoutine: TodayRoutine) {
        let viewModel = WorkplaceRoutineListViewModel()
        let vc = WorkplaceRoutineListViewController(
            viewModel: viewModel,
            workplaceName: todayRoutine.workplaceName,
            routines: todayRoutine.routines
        )
        navigationController.pushViewController(vc, animated: true)
    }
    
    func moveToManageAttendance() {
        let viewModel = ManageAttendanceViewModel()
        let vc = ManageAttendanceViewController(viewModel: viewModel, coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func moveToAttendanceHistory(navTitle: String) {
        let viewModel = AttendanceHistoryViewModel()
        let vc = AttendanceHistoryViewController(viewModel: viewModel, navTitle: navTitle)
        navigationController.pushViewController(vc, animated: true) // TODO: - 애니메이션 자연스러운지 다같이 확인해봐야함.
    }
    
    func presentInviteCodeSheet() {
        let viewModel = InviteCodeSheetViewModel()
        let vc = InviteCodeSheetViewController(viewModel: viewModel)
        vc.modalPresentationStyle = .pageSheet
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [
                .custom { _ in 250 }
            ]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 12
        }
        
        navigationController.present(vc, animated: true)
    }
    
    func presentConfirmationModal() {
        let vc = AttendanceConfirmModalViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        navigationController.present(vc, animated: true)
    }
    
    func removeChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}
