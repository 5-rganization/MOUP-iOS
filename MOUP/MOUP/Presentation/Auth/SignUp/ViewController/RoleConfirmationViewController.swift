//
//  RoleConfirmationViewController.swift
//  MOUP
//
//  Created by 송규섭 on 9/3/25.
//

import UIKit
import RxSwift
import RxRelay

class RoleConfirmationViewController: UIViewController {
    // MARK: - Properties
    let userRole: UserRole
    private let roleConfirmationView = RoleConfirmationView()
    private let disposeBag = DisposeBag()
    internal let confirmButtonTapRelay = PublishRelay<Void>() // 상위 vc 확인 버튼 이벤트 전달용 relay

    // MARK: - loadView
    override func loadView() {
        view = roleConfirmationView
    }

    // MARK: - Initializer
    init(userRole: UserRole) {
        self.userRole = userRole
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
}

private extension RoleConfirmationViewController {
    // MARK: - configure
    func configure() {
        setStyles()
        setBindings()
    }

    // MARK: - setStyles
    func setStyles() {
        roleConfirmationView.update(by: userRole)
    }

    // MARK: - setBindings
    func setBindings() {
        roleConfirmationView.rx.cancelButtonTap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.dismiss(animated: false)
            })
            .disposed(by: disposeBag)

        roleConfirmationView.rx.confirmButtonTap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.confirmButtonTapRelay.accept(())
                owner.dismiss(animated: false)
            })
            .disposed(by: disposeBag)
    }
}
