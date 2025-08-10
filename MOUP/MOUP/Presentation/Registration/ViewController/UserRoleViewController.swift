//
//  UserRoleViewController.swift
//  MOUP
//
//  Created by 송규섭 on 8/10/25.
//

import UIKit
import RxSwift

class UserRoleViewController: UIViewController {
    // MARK: - Properties
    private let userRoleView = UserRoleView()
    private let disposeBag = DisposeBag()

    // MARK: - loadView
    override func loadView() {
        view = userRoleView
    }

    // MARK: - Initializer
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
}

private extension UserRoleViewController {
    // MARK: - configure
    func configure() {
        setBindings()
    }

    // MARK: - setBindings
    func setBindings() {
        userRoleView.rx.selectedRole.subscribe(onNext: { role in
            print(role)
        })
        .disposed(by: disposeBag)

        userRoleView.rx.startButtonTap.subscribe(onNext: {
            print("시작하기 탭")
        })
        .disposed(by: disposeBag)
    }
}
