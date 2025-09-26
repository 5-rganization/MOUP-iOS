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
    
    private lazy var viewModel = RoutineSelectionViewModel()
    private lazy var routineSelectionVC = RoutineSelectionViewController(viewModel: viewModel)
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        routineSelectionVC.coordinator = self
        navigationController.pushViewController(routineSelectionVC, animated: true)
    }
    
    func showAddRoutineViewController() {
        let viewModel = AddRoutineViewModel()
        let addRoutineVC = AddRoutineViewController(viewModel: viewModel)
        navigationController.pushViewController(addRoutineVC, animated: true)
    }
    
    func showRoutineDetail(with state: RoutineRowViewState) {
        let existingTitle = state.name
        let existingTime = state.time
        let existingTodos: [TodoItem] = [
            TodoItem(text: "매장 오픈 준비"),
            TodoItem(text: "발주 확인")
        ]
        
        let vm = AddRoutineViewModel()
        let vc = AddRoutineViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
}
