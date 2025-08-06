//
//  InputNameViewController.swift
//  MOUP
//
//  Created by 양원식 on 7/25/25.
//

import UIKit
import SnapKit
import RxSwift

final class InputNameViewController: UIViewController {
    
    // MARK: - Properties
    private let inputNameView = InputNameView()
    private let viewModel: InputNameViewModel
    private let disposeBag = DisposeBag()
    
    
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = inputNameView
    }
    
    // VC일 때
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK: - Initializer
    
    init(viewModel: InputNameViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "compile error")
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc
    private func didTapBack() {
        print("Back 버튼 클릭")
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UI Methods

private extension InputNameViewController {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
        setBinding()
    }
    
    // MARK: - setBinding
    func setHierarchy() { }
    func setStyles() {
        setNavigationBar(title: "근무지 입력", backAction: #selector(didTapBack))
    }
    func setConstraints() { }
    func setActions() { }
    func setBinding() {
        inputNameView.getTextField.rx.text.orEmpty
            .bind(to: viewModel.nameText)
            .disposed(by: disposeBag)
        
        inputNameView.getRegisterButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.viewModel.confirmName()
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.isValidName
            .drive(onNext: { [weak self] isValid in
                self?.inputNameView.getRegisterButton.isEnabled = isValid
                self?.inputNameView.getRegisterButton.update(title: "완료", isSecondary: false)
            })
            .disposed(by: disposeBag)
    }
}
