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
    
    func showAddRoutineViewController(onSave: @escaping (Routine) -> Void) {
        let viewModel = AddRoutineViewModel()
        let addRoutineVC = AddRoutineViewController(viewModel: viewModel)
        addRoutineVC.onSave = onSave
        navigationController.pushViewController(addRoutineVC, animated: true)
    }
    
    func showRoutineDetail(with state: RoutineRowViewState) {
        let vm = AddRoutineViewModel()
        let vc = AddRoutineViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
}
