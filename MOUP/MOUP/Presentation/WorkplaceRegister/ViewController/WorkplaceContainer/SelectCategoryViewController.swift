//
//  SelectCategoryViewController.swift
//  MOUP
//
//  Created by 양원식 on 7/24/25.
//

import UIKit
import SnapKit
import RxSwift

final class SelectCategoryViewController: UIViewController {
    
    // MARK: - Properties
    private let selectCategoryView = SelectCategoryView()
    private let viewModel: SelectCategoryViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = selectCategoryView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.resetToConfirmedCategoryIfNeeded()
    }

    
    // VC일 때
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK: - Initializer
    
    init(viewModel: SelectCategoryViewModel) {
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
        viewModel.resetSelectedCategory()
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UI Methods

private extension SelectCategoryViewController {
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
        setNavigationBar(title: "카테고리", backAction: #selector(didTapBack))
    }
    func setConstraints() { }
    func setActions() {
        let radioButtons: [(RadioButtonView, String)] = [
            (selectCategoryView.getRestaurantRadioButton, "음식점"),
            (selectCategoryView.getCafeRadioButton, "카페"),
            (selectCategoryView.getCvsRadioButton, "편의점"),
            (selectCategoryView.getTheaterRadioButton, "영화관"),
            (selectCategoryView.getEtcRadioButton, "기타")
        ]
        
        radioButtons.forEach { (button, category) in
            button.rx.tap
                .bind { [weak self] in
                    self?.viewModel.didSelectCategory.onNext(category)
                }
                .disposed(by: disposeBag)
        }
    }
    
    func setBinding() {
        let radioButtons: [(RadioButtonView, String)] = [
            (selectCategoryView.getRestaurantRadioButton, "음식점"),
            (selectCategoryView.getCafeRadioButton, "카페"),
            (selectCategoryView.getCvsRadioButton, "편의점"),
            (selectCategoryView.getTheaterRadioButton, "영화관"),
            (selectCategoryView.getEtcRadioButton, "기타")
        ]

        // 완료 버튼 탭 처리
        selectCategoryView.getRegisterButton.rx.tap
            .bind { [weak self] in
                self?.viewModel.didTapConfirm.onNext(())
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)

        // 완료 버튼 활성화 상태
        viewModel.isCategorySelected
            .drive(onNext: { [weak self] isSelected in
                self?.selectCategoryView.getRegisterButton.isEnabled = isSelected
                self?.selectCategoryView.getRegisterButton.update(title: "완료", isSecondary: false)
            })
            .disposed(by: disposeBag)

        // 사용자가 버튼을 눌렀을 때 UI 즉시 반영
        viewModel.selectedCategory
            .observe(on: MainScheduler.instance)
            .compactMap { $0 }
            .bind { selected in
                radioButtons.forEach { (button, category) in
                    button.setSelected(category == selected)
                }
            }
            .disposed(by: disposeBag)

        // 화면이 진입되었을 때 마지막 확정값 기준으로 다시 반영
        viewModel.confirmedCategory
            .take(1) // 최초 진입 시 1번만 적용
            .observe(on: MainScheduler.instance)
            .bind { confirmed in
                radioButtons.forEach { (button, category) in
                    button.setSelected(category == confirmed)
                }
            }
            .disposed(by: disposeBag)
    }
}
