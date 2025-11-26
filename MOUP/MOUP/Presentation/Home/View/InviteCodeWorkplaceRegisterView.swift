//
//  InviteCodeWorkplaceRegisterView.swift
//  MOUP
//
//  Created by 양원식 on 11/15/25.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

final class InviteCodeWorkplaceRegisterView: UIView {
    
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .fill
        $0.distribution = .fill
    }
    
    // MARK: - 컨테이너
    private let payContainerView = PayContainerView()
    private let workingConditionsContainerView = WorkingConditionsContainerView()
    private let colorLabelContainerView = ColorLabelContainerView()
    
    // MARK: - UI Components
    fileprivate let navigationBar = BaseNavigationBar(title: "")
    private let registerButton = BaseButton(title: "등록하기", isSecondary: true)
    
    // MARK: - Getter
    var getWorkingConditionsContainerView: WorkingConditionsContainerView {
        workingConditionsContainerView
    }
    var getPayContainerView: PayContainerView {
        payContainerView
    }
    var getColorLabelContainerView: ColorLabelContainerView {
        colorLabelContainerView
    }
    var getRegisterButton: BaseButton {
        registerButton
    }

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Public Methods
}

private extension InviteCodeWorkplaceRegisterView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            navigationBar,
            scrollView
        )
        
        scrollView.addSubviews(
            contentView
        )
        
        contentView.addSubviews(
            stackView,
            registerButton
        )
        
        stackView.addArrangedSubviews(
            payContainerView,
            workingConditionsContainerView,
            colorLabelContainerView
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalTo(safeAreaLayoutGuide)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.trailing.leading.equalTo(safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.leading.trailing.equalToSuperview()
        }
        
        registerButton.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(71)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(45)
            $0.bottom.equalToSuperview().inset(12)
        }
    }
}

extension Reactive where Base: InviteCodeWorkplaceRegisterView {
    var navBackBtnTapped: ControlEvent<Void> {
        return base.navigationBar.rx.backBtnTapped
    }
}
