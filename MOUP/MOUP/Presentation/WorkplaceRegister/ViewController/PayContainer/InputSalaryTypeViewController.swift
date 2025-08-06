//
//  InputSalaryTypeViewController.swift
//  MOUP
//
//  Created by 양원식 on 7/25/25.
//

import UIKit
import SnapKit
import RxSwift

final class InputSalaryTypeViewController: UIViewController {
    
    // MARK: - Properties
    private let inputSalaryTypeView = InputSalaryTypeView()
    private let viewModel: InputSalaryTypeViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = inputSalaryTypeView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        inputSalaryTypeView.getTextField.text = viewModel.currentFormattedSalaryText()
    }

    
    // VC일 때
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK: - Initializer
    
    init(viewModel: InputSalaryTypeViewModel) {
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

private extension InputSalaryTypeViewController {
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
        setNavigationBar(title: "시급", backAction: #selector(didTapBack))
    }
    func setConstraints() { }
    func setActions() { }
    func setBinding() {
        inputSalaryTypeView.getTextField.rx.controlEvent(.editingChanged)
            .withLatestFrom(inputSalaryTypeView.getTextField.rx.text.orEmpty)
            .map { $0.replacingOccurrences(of: ",", with: "") }
            .do(onNext: { [weak self] raw in
                guard let number = Int(raw) else { return }
                let formatted = NumberFormatter.formattedDecimal(from: raw)
                
                // 커서 위치 보존 없이 setText만 수행
                self?.inputSalaryTypeView.getTextField.text = formatted
            })
            .bind(to: viewModel.salaryText)
            .disposed(by: disposeBag)

        inputSalaryTypeView.getRegisterButton.rx.tap
            .bind { [weak self] in
                self?.viewModel.confirmSalary()
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)

        viewModel.isValidSalary
            .drive(onNext: { [weak self] isValid in
                self?.inputSalaryTypeView.getRegisterButton.isEnabled = isValid
                self?.inputSalaryTypeView.getRegisterButton.update(title: "완료", isSecondary: false)
            })
            .disposed(by: disposeBag)

        viewModel.salaryTypeTitleOutput
            .drive(inputSalaryTypeView.rx.titleText)
            .disposed(by: disposeBag)

        viewModel.placeholderText
            .drive(inputSalaryTypeView.rx.placeholderText)
            .disposed(by: disposeBag)
    }
}
