//
//  WorkplaceRegisterCoordinator.swift
//  MOUP
//
//  Created by 양원식 on 7/24/25.
//

import SwiftUI
import UIKit

final class WorkplaceRegisterCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    private let navigationController: UINavigationController
    private let isOwnerInjected: Bool
    private let registerMode: WorkplaceRegisterMode

    init(navigationController: UINavigationController, isOwner: Bool, mode: WorkplaceRegisterMode) {
        self.navigationController = navigationController
        self.isOwnerInjected = isOwner
        self.registerMode = mode
    }

    func start() {
        let useCase = WorkplaceUseCase(
            workplaceRepository: WorkplaceRepository(workplaceService: WorkplaceService())
        )

        let mode: WorkplaceRegisterView.Mode = {
            switch registerMode {
            case .create: return .create
            case .edit(let workplaceId): return .edit(workplaceId: workplaceId)
            }
        }()

        // 사장님 화면은 Task 6에서 붙인다. 그 전까지는 알바생 화면만 띄운다.
        let hostingVC = UIHostingController(
            rootView: WorkplaceRegisterView(navigationController: navigationController,
                                            mode: mode,
                                            workplaceUseCase: useCase)
        )
        hostingVC.hidesBottomBarWhenPushed = true
        navigationController.navigationBar.isHidden = true
        navigationController.pushViewController(hostingVC, animated: true)
    }
}
