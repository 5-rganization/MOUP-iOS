//
//  SelectPayTypeView.swift
//  MOUP
//
//  Created by 양원식 on 7/25/25.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

final class SelectPayTypeView: UIView {
    // MARK: - Properties
    
    // MARK: - UI Components
    fileprivate let navigationBar = BaseNavigationBar(title: "급여 유형")
    
    private let title = UILabel().then {
        $0.text = "급여 유형을 선택해주세요."
        $0.textColor = .gray900
        $0.font = .headBold(18)
    }
    
    private let registerButton = BaseButton(title: "완료").then {
        $0.isEnabled = false
    }
    private let monthlyRadioButton = RadioButtonView(title: "매월", type: .none(selectedRadioButton: UIImage(named: "selectedRadioButton")!, unselectedRadioButton: UIImage(named: "unselectedRadioButton")!))
    private let weeklyRadioButton = RadioButtonView(title: "매주", type: .none(selectedRadioButton: UIImage(named: "selectedRadioButton")!, unselectedRadioButton: UIImage(named: "unselectedRadioButton")!))
    private let dailyRadioButton = RadioButtonView(title: "매일", type: .none(selectedRadioButton: UIImage(named: "selectedRadioButton")!, unselectedRadioButton: UIImage(named: "unselectedRadioButton")!))
    
    // MARK: - Getter
    var getMonthlyRadioButton: RadioButtonView { monthlyRadioButton }
    var getWeeklyRadioButton: RadioButtonView { weeklyRadioButton }
    var getDailyRadioButton: RadioButtonView { dailyRadioButton }
    var getRegisterButton: BaseButton { registerButton }
    
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

private extension SelectPayTypeView {
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
            title,
            monthlyRadioButton,
            weeklyRadioButton,
            dailyRadioButton,
            registerButton
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
        
        title.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(16)
        }
        
        monthlyRadioButton.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        weeklyRadioButton.snp.makeConstraints {
            $0.top.equalTo(monthlyRadioButton.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        dailyRadioButton.snp.makeConstraints {
            $0.top.equalTo(weeklyRadioButton.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        registerButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(45)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(12)
        }
    }
}

extension Reactive where Base: SelectPayTypeView {
    var navBackBtnTapped: ControlEvent<Void> {
        return base.navigationBar.rx.backBtnTapped
    }
}
