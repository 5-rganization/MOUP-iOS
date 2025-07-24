//
//  WorkplaceContainerViewController.swift
//  MOUP
//
//  Created by 양원식 on 7/24/25.
//

import UIKit
import RxSwift

final class WorkplaceContainerViewController: UIViewController {
    
    // MARK: - Properties
    private let workplaceContainerView = WorkplaceContainerView()
    private let viewModel: WorkplaceContainerViewModel
    private let disposeBag = DisposeBag()
    
    weak var coordinator: WorkplaceRegisterCoordinatorProtocol?
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = workplaceContainerView
    }
    
    // VC일 때
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK: - Initializer
    
    init(viewModel: WorkplaceContainerViewModel, coordinator: WorkplaceRegisterCoordinatorProtocol?) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "compile error")
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc
    func didTapSomeButton(_ sender: UIButton) {
        
    }
}

// MARK: - UI Methods

private extension WorkplaceContainerViewController {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
        setBinding()
    }
    
    // MARK: - setBinding
    func setHierarchy() { }
    func setStyles() { }
    func setConstraints() { }
    func setActions() { }
    func setBinding() {
        workplaceContainerView.getCategoryRow.rx.tap
            .bind(to: viewModel.didTapCategory)
            .disposed(by: disposeBag)

        viewModel.showCategory
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.showSelectCategory()
            })
            .disposed(by: disposeBag)
    }
    
}
