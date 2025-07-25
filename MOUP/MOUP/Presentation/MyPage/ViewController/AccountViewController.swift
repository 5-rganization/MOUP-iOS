//
//  AccountViewController.swift
//  MOUP
//
//  Created by shinyoungkim on 7/25/25.
//

import UIKit
import RxSwift

final class AccountViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: MyPageCoordinator?
    
    private let accountView  = AccountView()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = accountView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
}

private extension AccountViewController {
    // MARK: - configure
    func configure() {
        setBindings()
    }
    
    // MARK: - setBindings
    func setBindings() {
        accountView.rx.deleteAccountTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.coordinator?.showDeleteAccountModal()
            })
            .disposed(by: disposeBag)
    }
}
