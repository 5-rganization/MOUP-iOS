//
//  SelectedWorkplaceViewController.swift
//  MOUP
//
//  Created by 양원식 on 11/9/25.
//

import UIKit
import RxSwift
import RxRelay

final class SelectedWorkplaceViewController: UIViewController {
    
    // MARK: - Properties
    private let selectedWorkplaceView = SelectedWorkplaceView()
    private let viewModel: SelectedWorkplaceViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = selectedWorkplaceView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 화면 진입 시 근무지 목록 조회
        viewModel.fetchTrigger.accept(())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK: - Initializer
    init(viewModel: SelectedWorkplaceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "Storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UI Methods
private extension SelectedWorkplaceViewController {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
        setBinding()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() { }
    
    // MARK: - setStyles
    func setStyles() { }
    
    // MARK: - setConstraints
    func setConstraints() { }
    
    // MARK: - setActions
    func setActions() {
        selectedWorkplaceView.getRegisterButton.rx.tap
            .bind(to: viewModel.didTapConfirm)
            .disposed(by: disposeBag)
    }
    
    // MARK: - setBinding
    func setBinding() {
        selectedWorkplaceView.rx.navBackBtnTapped.asDriver()
            .drive(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)
        
        // 근무지 목록 바인딩
        viewModel.workplaces
            .asDriver()
            .drive(onNext: { [weak self] workplaces in
                self?.selectedWorkplaceView.updateWorkplaceList(with: workplaces)
            })
            .disposed(by: disposeBag)
        
        // 근무지 선택 시 ViewModel에 전달
        selectedWorkplaceView.selectedWorkplace
            .bind(to: viewModel.selectedWorkplace)
            .disposed(by: disposeBag)
        
        // 완료 시 액션
        viewModel.confirmSelectedWorkplace
            .subscribe(onNext: { [weak self] workplace in
                print("선택된 근무지 ID:", workplace.id)
                print("선택된 근무지 이름:", workplace.name)
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
