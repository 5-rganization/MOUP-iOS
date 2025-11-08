//
//  InviteCodeResultView.swift
//  MOUP
//
//  Created by 송규섭 on 11/3/25.
//

import UIKit
import RxSwift
import RxCocoa

final class InviteCodeResultView: UIView {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    fileprivate let navigationBar = BaseNavigationBar(title: "새 근무지")
    
    private let containerView = UIView().then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray400.cgColor
    }
    
    private let workplaceNameLabel = UILabel().then {
        $0.font = .headBold(18)
        $0.textColor = .gray900
    }
    
    private let categoryLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }
    
    fileprivate let registerWorkplaceInfoBtn = UIButton().then {
        $0.backgroundColor = .clear
    }
    
    private let calendarIcon = UIImageView().then {
        $0.image = .calendar
        $0.tintColor = .gray700
    }
    
    private let registerBtnTitleLabel = UILabel().then {
        $0.text = "근무지 정보 등록하기"
        $0.textColor = .gray900
        $0.font = .bodyMedium(16)
    }
    
    private let rightIcon = UIImageView().then {
        $0.image = .attendanceRightChevron
        $0.tintColor = .gray700
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
    func update(with workplace: InviteCodeWorkplace) {
        workplaceNameLabel.text = workplace.workplaceName
        categoryLabel.text = workplace.categoryName
    }
}

private extension InviteCodeResultView {
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
            containerView
        )
        containerView.addSubviews(
            workplaceNameLabel,
            categoryLabel,
            registerWorkplaceInfoBtn
        )
        registerWorkplaceInfoBtn.addSubviews(
            calendarIcon,
            registerBtnTitleLabel,
            rightIcon
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
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(21)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(143)
        }
        
        workplaceNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.equalToSuperview().inset(16)
            $0.height.equalTo(23)
        }
        
        categoryLabel.snp.makeConstraints {
            $0.top.equalTo(workplaceNameLabel.snp.bottom).offset(2)
            $0.leading.equalTo(workplaceNameLabel)
        }
        
        registerWorkplaceInfoBtn.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(20)
            $0.height.equalTo(24)
        }
        
        calendarIcon.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }
        
        registerBtnTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(calendarIcon.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
        }
        
        rightIcon.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.width.equalTo(6)
            $0.height.equalTo(12)
        }
    }
}

extension Reactive where Base: InviteCodeResultView {
    var navBackBtnTapped: ControlEvent<Void> {
        return base.navigationBar.rx.backBtnTapped
    }
    
    var registerInfoBtnTapped: ControlEvent<Void> {
        return base.registerWorkplaceInfoBtn.rx.tap
    }
}
