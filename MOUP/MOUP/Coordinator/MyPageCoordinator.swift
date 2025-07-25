//
//  MyPageCoordinator.swift
//  MOUP
//
//  Created by 양원식 on 7/14/25.
//

import UIKit

final class MyPageCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let myPageVC = MyPageViewController()
        myPageVC.coordinator = self
        navigationController.pushViewController(myPageVC, animated: false)
    }
    
    func showAccountViewController() {
        let accountVC = AccountViewController()
        accountVC.coordinator = self
        navigationController.pushViewController(accountVC, animated: true)
    }
    
    func showDeleteAccountModal() {
        let deleteAccountModalVC = DeleteAccountModalViewController()
        deleteAccountModalVC.modalPresentationStyle = .overFullScreen
        navigationController.present(deleteAccountModalVC, animated: false)
    }
}
