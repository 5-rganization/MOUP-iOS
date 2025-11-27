//
//  SelectColorLabelView.swift
//  MOUP
//
//  Created by 양원식 on 7/25/25.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

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
    func setStyles() {}
    func setConstraints() { }
    func setActions() {
        let radioButtons: [(RadioButtonView, String)] = [
            (selectColorLabelView.getRedRadioButton, LabelColor.red.displayStr),
            (selectColorLabelView.getOrangeRadioButton, LabelColor.orange.displayStr),
            (selectColorLabelView.getYellowRadioButton, LabelColor.yellow.displayStr),
            (selectColorLabelView.getGreenRadioButton, LabelColor.green.displayStr),
            (selectColorLabelView.getBlueRadioButton, LabelColor.blue.displayStr),
            (selectColorLabelView.getPurpleRadioButton, LabelColor.purple.displayStr),
            (selectColorLabelView.getIndigoRadioButton, LabelColor.indigo.displayStr)
        ]

        radioButtons.forEach { (button, color) in
            button.rx.tap
                .bind { [weak self] in
                    self?.viewModel.didSelectColor.onNext(color)
                }
                .disposed(by: disposeBag)
        }

        selectColorLabelView.getConfirmButton.rx.tap
            .bind { [weak self] in
                self?.viewModel.didTapConfirm.onNext(())
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    func setBinding() {
        selectColorLabelView.rx.navBackBtnTapped.asDriver()
            .drive(with: self) { owner, _ in
                owner.viewModel.resetSelectedColor()
                owner.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)
        
        let radioButtons: [(RadioButtonView, String)] = [
            (selectColorLabelView.getRedRadioButton, LabelColor.red.displayStr),
            (selectColorLabelView.getOrangeRadioButton, LabelColor.orange.displayStr),
            (selectColorLabelView.getYellowRadioButton, LabelColor.yellow.displayStr),
            (selectColorLabelView.getGreenRadioButton, LabelColor.green.displayStr),
            (selectColorLabelView.getBlueRadioButton, LabelColor.blue.displayStr),
            (selectColorLabelView.getPurpleRadioButton, LabelColor.purple.displayStr),
            (selectColorLabelView.getIndigoRadioButton, LabelColor.indigo.displayStr)
        ]

        viewModel.isColorSelected
            .drive(onNext: { [weak self] isSelected in
                self?.selectColorLabelView.getConfirmButton.isEnabled = isSelected
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
