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

        if isOwnerInjected {
            push(UIHostingController(
                rootView: OwnerWorkplaceRegisterView(navigationController: navigationController,
                                                      mode: mode,
                                                      workplaceUseCase: useCase)
            ))
        } else {
            push(UIHostingController(
                rootView: WorkplaceRegisterView(navigationController: navigationController,
                                                mode: mode,
                                                workplaceUseCase: useCase)
            ))
        }
    }

    private func push(_ vc: UIViewController) {
        vc.hidesBottomBarWhenPushed = true
        navigationController.navigationBar.isHidden = true
        navigationController.pushViewController(vc, animated: true)
    }
}
