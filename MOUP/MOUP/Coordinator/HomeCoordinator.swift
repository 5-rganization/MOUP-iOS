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
    private let workplaceService: WorkplaceServiceProtocol
    private let workplaceRepository: WorkplaceRepositoryProtocol
    private let workplaceUseCase: WorkplaceUseCaseProtocol
    private let attendanceService: AttendanceServiceProtocol
    private let attendanceRepository: AttendanceRepositoryProtocol
    private let attendanceUseCase: AttendanceUseCaseProtocol
    private var userRole: UserRole
    private let notificationService: NotificationServiceProtocol
    private let notificationRepository: NotificationRepositoryProtocol
    private let notificationUseCase: NotificationUseCaseProtocol
    private let draftRoutineStorage: DraftRoutineStorageProtocol
    
    init(navigationController: UINavigationController, userRole: UserRole) {
        self.navigationController = navigationController
        self.homeService = HomeService()
        self.homeRepository = HomeRepository(homeService: homeService)
        self.homeUseCase = HomeUseCase(homeRepository: homeRepository)
        self.routineService = RoutineService()
        self.routineRepository = RoutineRepository(routineService: routineService)
        self.routineUseCase = RoutineUseCase(routineRepository: routineRepository)
        self.workplaceService = WorkplaceService()
        self.workplaceRepository = WorkplaceRepository(workplaceService: workplaceService)
        self.workplaceUseCase = WorkplaceUseCase(workplaceRepository: workplaceRepository)
        self.attendanceService = AttendanceService()
        self.attendanceRepository = AttendanceRepository(attendanceService: attendanceService)
        self.attendanceUseCase = AttendanceUseCase(attendanceRepository: attendanceRepository)
        self.userRole = userRole
        self.notificationService = NotificationService()
        self.notificationRepository = NotificationRepository(notificationService: notificationService)
        self.notificationUseCase = NotificationUseCase(notificationRepository: notificationRepository)
        self.draftRoutineStorage = DraftRoutineStorage()
    }
    
    func start() {
        let homeVM = HomeViewModel(
            userRole: userRole,
            homeUseCase: homeUseCase,
            attendanceUseCase: attendanceUseCase,
            notificationUseCase: notificationUseCase
        )
        let homeVC = HomeViewController(
            coordinator: self,
            homeViewModel: homeVM,
            userRole: userRole
        )
        navigationController.pushViewController(homeVC, animated: false)
    }
    
    func presentWorkplaceRegistrationSheet() {
        let coordinator = WorkplaceRegisterSheetCoordinator(
            navigationController: navigationController,
            workplaceUseCase: workplaceUseCase
        )
        coordinator.coordinator = self
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    
    func moveToDirectRegistration() { // 직접 등록
        print("moveToDirectRegistration")
        let role = UserDefaultsManager.shared.userRole
        let isOwner = (role == "ROLE_OWNER")

        print("UserRole: \(role ?? "nil"), isOwner: \(isOwner)")

        let coordinator = WorkplaceRegisterCoordinator(
            navigationController: navigationController,
            isOwner: isOwner
        )
        
        childCoordinators.append(coordinator)

        DispatchQueue.main.async {
            coordinator.start()
        }
    }

    
    func moveToAllRoutine() {
        let viewModel = AllRoutineViewModel(routineUseCase: routineUseCase)
        let vc = AllRoutineViewController(viewModel: viewModel)
        vc.coordinator = self
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
    
    func moveToManageAttendance(workplaceId: Int) {
        let viewModel = ManageAttendanceViewModel(
            attendanceUseCase: attendanceUseCase,
            workplaceId: workplaceId
        )
        let vc = ManageAttendanceViewController(
            viewModel: viewModel,
            coordinator: self
        )
        navigationController.pushViewController(vc, animated: true)
    }
    
    func moveToAttendanceHistory(workplaceId: Int, workerId: Int? = nil, navTitle: String) {
        
        let viewModel = AttendanceHistoryViewModel(
            userRole: userRole,
            workplaceId: workplaceId,
            workerId: workerId,
            attendanceUseCase: attendanceUseCase
        )
        let vc = AttendanceHistoryViewController(
            viewModel: viewModel,
            workplaceName: navTitle,
        )
        navigationController.pushViewController(vc, animated: true) // TODO: - 애니메이션 자연스러운지 다같이 확인해봐야함.
    }
    
    func presentInviteCodeSheet(workplaceId: Int) {
        let viewModel = InviteCodeSheetViewModel(workplaceUseCase: workplaceUseCase)
        let vc = InviteCodeSheetViewController(
            viewModel: viewModel,
            workplaceId: workplaceId
        )
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
    
    func presentConfirmationModal(onConfirm: (() -> Void)? = nil) {
        let vc = AttendanceConfirmModalViewController()
        vc.onConfirm = onConfirm
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        navigationController.present(vc, animated: true)
    }
    
    func removeChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
    
    func showNotificationList() {
        let viewModel = NotificationListViewModel(notificationUseCase: notificationUseCase)
        let notificationListVC = NotificationListViewController(viewModel: viewModel)
        navigationController.pushViewController(notificationListVC, animated: true)
    }
    
    func showAddRoutineViewController(onSave: @escaping (RoutineSummary) -> Void) {
        let viewModel = AddRoutineViewModel(
            routineUseCase: routineUseCase,
            storage: draftRoutineStorage
        )
        let addRoutineVC = AddRoutineViewController(viewModel: viewModel)
        addRoutineVC.onSave = onSave
        navigationController.pushViewController(addRoutineVC, animated: true)
    }
    
    func showEditRoutineViewController(
        routine: RoutineSummary,
        onEdit: @escaping (RoutineSummary) -> Void
    ) {
        let vm = EditRoutineViewModel(
            routineId: routine.routineId,
            routineUseCase: routineUseCase
        )
        let vc = EditRoutineViewController(viewModel: vm)
        vc.onEdit = onEdit
        navigationController.pushViewController(vc, animated: true)
    }
}
