//
//  MyPageViewController.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import UIKit
import RxSwift

final class MyPageViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: MyPageCoordinator?
    
    private let mypageView = MyPageView()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = mypageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
}

private extension MyPageViewController {
    // MARK: - configure
    func configure() {
        setStyles()
        setBindings()
    }
    
    // MARK: - setStyles
    func setStyles() {
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - setBindings
    func setBindings() {
        mypageView.rx.editButtonTapped
            .subscribe(onNext: {
                print("editButton tapped")
            })
            .disposed(by: disposeBag)
        
        mypageView.rx.logoutButtonTapped
            .subscribe(onNext: {
                print("logoutButton tapped")
            })
            .disposed(by: disposeBag)
        
        mypageView.rx.menuTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, menu in
                switch menu {
                case .account:
                    owner.coordinator?.showAccountViewController()
                case .contact:
                    print("contact tapped")
                case .info:
                    print("info tapped")
                }
            })
            .disposed(by: disposeBag)
    }
}
