//
//  RoutineSelectionCoordinator.swift
//  MOUP
//
//  Created by 신영 on 9/22/25.
//

import UIKit

final class RoutineSelectionCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    let navigationController: UINavigationController
    
    private let routineService: RoutineServiceProtocol
    private let routineRepository: RoutineRepositoryProtocol
    private let routineUseCase: RoutineUseCaseProtocol
    
    private let draftRoutineStorage: DraftRoutineStorageProtocol
    
    private lazy var viewModel: RoutineSelectionViewModel = {
        return RoutineSelectionViewModel(routineUseCase: routineUseCase)
    }()
    
    private lazy var routineSelectionVC: RoutineSelectionViewController = {
        return RoutineSelectionViewController(viewModel: viewModel)
    }()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        self.routineService = RoutineService()
        self.routineRepository = RoutineRepository(routineService: routineService)
        self.routineUseCase = RoutineUseCase(routineRepository: routineRepository)
        
        self.draftRoutineStorage = DraftRoutineStorage()
    }
    
    func start() {
        routineSelectionVC.coordinator = self
        navigationController.pushViewController(routineSelectionVC, animated: true)
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
        Task {
            do {
                let routineDetail = try await routineUseCase.fetchRoutineDetail(
                    routineId: routine.routineId
                )

                await MainActor.run {
                    let vm = EditRoutineViewModel(
                        routine: routineDetail.summary,
                        tasks: routineDetail.tasks,
                        routineUseCase: routineUseCase
                    )
                    let vc = EditRoutineViewController(viewModel: vm)
                    vc.onEdit = onEdit
                    navigationController.pushViewController(vc, animated: true)
                }
            } catch {
                await MainActor.run {
                    let alert = NoticeModalViewController(
                        title: "오류",
                        comment: "루틴 정보를 불러올 수 없습니다."
                    )
                    alert.modalTransitionStyle = .crossDissolve

                    if let presenter = navigationController.visibleViewController {
                        presenter.present(alert, animated: true)
                    } else {
                        navigationController.pushViewController(alert, animated: true)
                    }
                }
            }
        }
    }
}
