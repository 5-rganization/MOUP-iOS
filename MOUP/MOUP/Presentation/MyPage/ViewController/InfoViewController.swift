//
//  InfoViewController.swift
//  MOUP
//
//  Created by shinyoungkim on 8/11/25.
//

import UIKit
import RxSwift

enum PolicyKind {
    case termsOfService
    case privacyPolicy
}

extension PolicyKind {
    var fileName: String {
        switch self {
        case .termsOfService: return "service_terms"
        case .privacyPolicy: return "privacy_policy"
        }
    }
    
    var title: String {
        switch self {
        case .termsOfService: return "이용약관"
        case .privacyPolicy: return "개인정보처리방침"
        }
    }
}

final class InfoViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: MyPageCoordinator?
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let infoView = InfoView()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = infoView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
}

private extension InfoViewController {
    // MARK: - configure
    func configure() {
        setBindings()
    }
    
    // MARK: - setBindings
    func setBindings() {
        infoView.rx.backButtonTapped
            .bind(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        infoView.rx.menuTapped
            .bind(with: self) { owner, menu in
                switch menu {
                case .termsOfService:
                    owner.coordinator?.showPolicy(.termsOfService)
                case .privacyPolicy:
                    owner.coordinator?.showPolicy(.privacyPolicy)
                case .openSourceLicense:
                    owner.coordinator?.showOpenSourceLicense()
                }
            }
            .disposed(by: disposeBag)
    }
}
