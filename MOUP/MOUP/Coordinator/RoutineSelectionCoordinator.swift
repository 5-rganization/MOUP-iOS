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
    
    private let viewModel = RoutineSelectionViewModel()
    private lazy var routineSelectionVC = RoutineSelectionViewController(viewModel: viewModel)
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        routineSelectionVC.coordinator = self
        navigationController.pushViewController(routineSelectionVC, animated: true)
    }
    
//    func showAddRoutineViewController(onSave: @escaping (Routine) -> Void) {
//        let viewModel = AddRoutineViewModel()
//        let addRoutineVC = AddRoutineViewController(viewModel: viewModel)
//        addRoutineVC.onSave = onSave
//        navigationController.pushViewController(addRoutineVC, animated: true)
//    }
//    
//    func showEditRoutineViewController(routine: Routine, onEdit: @escaping (Routine) -> Void) {
//        let vm = EditRoutineViewModel(routine: routine)
//        let vc = EditRoutineViewController(viewModel: vm)
//        vc.onEdit = onEdit
//        navigationController.pushViewController(vc, animated: true)
//    }
    
    func showAddRoutineViewController(
        onSave: @escaping (Routine) -> Void
    ) {
        let vc = makeRoutineEditor(
            mode: .add,
            saveStrategy: AddSaveStrategy(createRoutineUseCase: CreateRoutineUseCase())
        )
        vc.onSaved = onSave
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showEditRoutineViewController(
        routine: Routine,
        onEdit: @escaping (Routine) -> Void
    ) {
        let vc = makeRoutineEditor(
            mode: .edit(initial: routine),
            saveStrategy: EditSaveStrategy(
                updateRoutineUseCase: UpdateRoutineUseCase(),
                routineID: routine.id
            )
        )
        vc.onSaved = onEdit
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func makeRoutineEditor(
        mode: RoutineEditorViewModel.Mode,
        saveStrategy: SaveStrategy
    ) -> RoutineEditorViewController {
        return RoutineEditorViewController(
            mode: mode,
            saveStratgy: saveStrategy
        )
    }
}
