//
//  SelectColorLabelView.swift
//  MOUP
//
//  Created by 양원식 on 7/25/25.
//

import UIKit
import SnapKit
import RxSwift

final class SelectColorLabelViewController: UIViewController {
    
    // MARK: - Properties
    private let selectColorLabelView = SelectColorLabelView()
    private let viewModel: SelectColorLabelViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = selectColorLabelView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.resetToConfirmedColorIfNeeded()
    }
    
    // VC일 때
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK: - Initializer
    
    init(viewModel: SelectColorLabelViewModel) {
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
        viewModel.resetSelectedColor()
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UI Methods

private extension SelectColorLabelViewController {
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
        setNavigationBar(title: "라벨 색상", backAction: #selector(didTapBack))
    }
    func setConstraints() { }
    func setActions() {
        let radioButtons: [(RadioButtonView, String)] = [
            (selectColorLabelView.getRedRadioButton, "빨강색"),
            (selectColorLabelView.getOrangeRadioButton, "주황색"),
            (selectColorLabelView.getYellowRadioButton, "노란색"),
            (selectColorLabelView.getGreenRadioButton, "초록색"),
            (selectColorLabelView.getBlueRadioButton, "파란색"),
            (selectColorLabelView.getPurpleRadioButton, "보라색"),
            (selectColorLabelView.getIndigoRadioButton, "남색")
        ]

        radioButtons.forEach { (button, color) in
            button.rx.tap
                .bind { [weak self] in
                    self?.viewModel.didSelectColor.onNext(color)
                }
                .disposed(by: disposeBag)
        }

        selectColorLabelView.getRegisterButton.rx.tap
            .bind { [weak self] in
                self?.viewModel.didTapConfirm.onNext(())
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    func setBinding() {
        let radioButtons: [(RadioButtonView, String)] = [
            (selectColorLabelView.getRedRadioButton, "빨강색"),
            (selectColorLabelView.getOrangeRadioButton, "주황색"),
            (selectColorLabelView.getYellowRadioButton, "노란색"),
            (selectColorLabelView.getGreenRadioButton, "초록색"),
            (selectColorLabelView.getBlueRadioButton, "파란색"),
            (selectColorLabelView.getPurpleRadioButton, "보라색"),
            (selectColorLabelView.getIndigoRadioButton, "남색")
        ]

        viewModel.isColorSelected
            .drive(onNext: { [weak self] isSelected in
                self?.selectColorLabelView.getRegisterButton.isEnabled = isSelected
                self?.selectColorLabelView.getRegisterButton.update(title: "완료", isSecondary: false)
            })
            .disposed(by: disposeBag)

        viewModel.selectedColor
            .observe(on: MainScheduler.instance)
            .compactMap { $0 }
            .bind { selected in
                radioButtons.forEach { (button, color) in
                    button.setSelected(color == selected)
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.confirmedColor
            .take(1)
            .observe(on: MainScheduler.instance)
            .bind { confirmed in
                radioButtons.forEach { (button, color) in
                    button.setSelected(color == confirmed)
                }
            }
            .disposed(by: disposeBag)

    }
}
