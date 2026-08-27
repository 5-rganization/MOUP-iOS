//
//  InviteCodeInputCoordinator.swift
//  MOUP
//
//  Created by 송규섭 on 10/18/25.
//

import SwiftUI
import UIKit
import RxSwift

final class InviteCodeInputCoordinator: Coordinator {

    weak var coordinator: WorkplaceRegisterSheetCoordinator?
    weak var homeCoordinator: HomeCoordinator?

    var childCoordinators = [Coordinator]()

    private let navigationController: UINavigationController
    private let workplaceUseCase: WorkplaceUseCaseProtocol

    init(
        navigationController: UINavigationController,
        workplaceUseCase: WorkplaceUseCaseProtocol,
        homeCoordinator: HomeCoordinator
    ) {
        self.navigationController = navigationController
        self.workplaceUseCase = workplaceUseCase
        self.homeCoordinator = homeCoordinator
    }
    
    func start() {
        let viewModel = InviteCodeInputViewModel(workplaceUseCase: workplaceUseCase)
        let vc = InviteCodeInputViewController(viewModel: viewModel)
        vc.hidesBottomBarWhenPushed = true
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func moveToInviteCodeResult(workplace: InviteCodeWorkplace, inviteCode: String) {
        let viewModel = InviteCodeResultViewModel(workplace: workplace, inviteCode: inviteCode)
        let vc = InviteCodeResultViewController(viewModel: viewModel, coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func moveToInviteCodeWorkplaceRegister(workplaceName: String, inviteCode: String) {
        let hostingVC = UIHostingController(
            rootView: InviteCodeWorkplaceRegisterView(navigationController: navigationController,
                                                        workplaceName: workplaceName,
                                                        inviteCode: inviteCode,
                                                        workplaceUseCase: workplaceUseCase,
                                                        onJoined: { [weak self] in self?.moveToHomeAfterJoin() })
        )
        hostingVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(hostingVC, animated: true)
    }
}

extension InviteCodeInputCoordinator {

    func moveToHomeAfterJoin() {
        guard let homeCoordinator else {
            print("homeCoordinator is nil — 홈 이동 불가")
            return
        }

        // 기존 스택 제거하고 home root 로 교체
        navigationController.setViewControllers([], animated: false)

        // 홈 화면 다시 시작
        homeCoordinator.start()
    }
}

