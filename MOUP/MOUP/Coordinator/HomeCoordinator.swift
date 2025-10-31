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
    private let homeUseCase: HomeUseCaseProtocol
    private let homeRepository: HomeRepositoryProtocol
    private let homeService: HomeServiceProtocol
    private let routineUseCase: RoutineUseCaseProtocol
    private let routineRepository: RoutineRepositoryProtocol
    private let routineService: RoutineServiceProtocol
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.homeService = HomeService()
        self.homeRepository = HomeRepository(homeService: homeService)
        self.homeUseCase = HomeUseCase(homeRepository: homeRepository)
        self.routineService = RoutineService()
        self.routineRepository = RoutineRepository(routineService: routineService)
        self.routineUseCase = RoutineUseCase(routineRepository: routineRepository)
    }
    
    func start() {
        guard let rawValue = UserDefaultsManager.shared.userRole,
        let role = UserRole(rawValue: rawValue) else { return }
        
        let homeVM = HomeViewModel(
            userRole: role,
            useCase: homeUseCase
        )
        let homeVC = HomeViewController(
            coordinator: self,
            homeViewModel: homeVM,
            userRole: role
        )
        navigationController.pushViewController(homeVC, animated: false)
    }
    
    func presentWorkplaceRegistrationSheet() {
        let coordinator = WorkplaceRegisterSheetCoordinator(navigationController: navigationController)
        coordinator.coordinator = self
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    
    func moveToDirectRegistration() { // 직접 등록
        print("moveToDirectRegistration")
        let coordinator = WorkplaceRegisterCoordinator(navigationController: navigationController)
        childCoordinators.append(coordinator)
        DispatchQueue.main.async {
            coordinator.start()
        }
    }
    
    func moveToAllRoutine() {
        let viewModel = AllRoutineViewModel(routineUseCase: routineUseCase)
        let vc = AllRoutineViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func moveToTodayRoutine() {
        let viewModel = TodayRoutineViewModel(routineUseCase: routineUseCase)
        let vc = TodayRoutineViewController(viewModel: viewModel)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func moveToWorkplaceRoutineList(with todayRoutine: TodayRoutine) {
        let viewModel = WorkplaceRoutineListViewModel(routineUseCase: routineUseCase)
        let vc = WorkplaceRoutineListViewController(
            viewModel: viewModel,
            workplaceName: todayRoutine.workplaceSummary.name,
            workId: todayRoutine.workId
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
