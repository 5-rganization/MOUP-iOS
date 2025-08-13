//
//  WorkRegisterCoordinator.swift
//  MOUP
//
//  Created by 양원식 on 8/8/25.
//

import UIKit

final class WorkRegisterCoordinator: WorkRegisterCoordinatorProtocol {
    var childCoordinators = [Coordinator]()
    private let navigationController: UINavigationController
    private lazy var selectColorLabelViewModel = SelectColorLabelViewModel()
    
    func start() {
        //let viewModel = WorkRegisterViewModel()
        
        let vc = WorkRegisterViewController(
            coordinator: self,
            workDatePickerViewModel: WorkDatePickerViewModel(),
            clockInVM: WorkTimePickerViewModel(),
            clockOutVM: WorkTimePickerViewModel(),
            lunchVM: WorkTimePickerViewModel()
        )
        
        navigationController.pushViewController(vc, animated: false)
    }
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func showSelectColorLabel() {
        let vc = SelectColorLabelViewController(viewModel: selectColorLabelViewModel)
        navigationController.pushViewController(vc, animated: true)
    }
}
