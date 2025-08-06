//
//  FilterCoordinator.swift
//  MOUP
//
//  Created by 서동환 on 8/4/25.
//

import UIKit

protocol FilterCoordinatorDelegate: AnyObject {
    func cancelled(_ coordinator: FilterCoordinator)
    func applyFilter(_ coordinator: FilterCoordinator, model: FilterModel?)
}

final class FilterCoordinator: Coordinator {
    
    // MARK: - Properties
    var childCoordinators = [Coordinator]()
    weak var delegate: FilterCoordinatorDelegate?
    let navigationController: UINavigationController
    
    // MARK: - Initializer
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Coordinator Methods
    func start() {
        let filterVM = FilterViewModel()
        let filterVC = FilterViewController(viewModel: filterVM)
        filterVC.delegate = self
        
        if let sheet = filterVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 12
        }
        
        navigationController.present(filterVC, animated: true)
    }
}

// MARK: - FilterVCDelegate
extension FilterCoordinator: FilterVCDelegate {
    func dismissGestureReceived() {
        delegate?.cancelled(self)
    }
    
    func applyButtonTapped(model: FilterModel?) {
        delegate?.applyFilter(self, model: model)
    }
}
