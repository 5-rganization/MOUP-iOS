//
//  OwnerWorkplaceContainerViewController.swift
//  MOUP
//
//  Created by 양원식 on 11/15/25.
//

import UIKit
import RxSwift

final class OwnerWorkplaceContainerViewController: UIViewController {
    
    // MARK: - Properties
    private let ownerView = OwnerWorkplaceContainerView()
    private let viewModel: WorkplaceContainerViewModel
    private let disposeBag = DisposeBag()
    
    weak var coordinator: WorkplaceRegisterCoordinatorProtocol?
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = ownerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK: - Initializer
    init(
        viewModel: WorkplaceContainerViewModel,
        coordinator: WorkplaceRegisterCoordinatorProtocol?
    ) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}


// MARK: - UI Setup
private extension OwnerWorkplaceContainerViewController {
    func configure() {
        setHierachy()
        setStyles()
        setConstraints()
        setActions()
        setBinding()
    }
    
    func setHierachy() { }
    func setStyles() { }
    func setConstraints() { }
    func setActions() { }
    
    
    func setBinding() {
        
        // 이름 입력
        ownerView.getNameRow.rx.tap
            .bind(to: viewModel.didTapName)
            .disposed(by: disposeBag)
        
        // 카테고리 선택
        ownerView.getCategoryRow.rx.tap
            .bind(to: viewModel.didTapCategory)
            .disposed(by: disposeBag)
        
        // 화면 이동
        viewModel.showName
            .bind(onNext: { [weak self] in
                self?.coordinator?.showInputName()
            })
            .disposed(by: disposeBag)
        
        viewModel.showCategory
            .bind(onNext: { [weak self] in
                self?.coordinator?.showSelectCategory()
            })
            .disposed(by: disposeBag)
        
        // 출력 바인딩
        viewModel.nameTextOutput
            .drive(ownerView.getNameRow.rx.labelValue)
            .disposed(by: disposeBag)
        
        viewModel.categoryTextOutput
            .drive(ownerView.getCategoryRow.rx.labelValue)
            .disposed(by: disposeBag)
    }
}
