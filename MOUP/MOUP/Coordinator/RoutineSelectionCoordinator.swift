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
        let vm = EditRoutineViewModel(
            routineId: routine.routineId,
            routineUseCase: routineUseCase
        )
        let vc = EditRoutineViewController(viewModel: vm)
        vc.onEdit = onEdit
        navigationController.pushViewController(vc, animated: true)
    }
}
