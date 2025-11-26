//
//  SelectPayCalculationView.swift
//  MOUP
//
//  Created by 양원식 on 7/25/25.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

final class SelectPayCalculationView: UIView {
    // MARK: - Properties
    
    // MARK: - UI Components
    fileprivate let navigationBar = BaseNavigationBar(title: "급여 계산")
    
    private let title = UILabel().then {
        $0.text = "급여 계산방법을 선택해주세요."
        $0.textColor = .gray900
        $0.font = .headBold(18)
    }
    
    private let registerButton = BaseButton(title: "완료").then {
        $0.isEnabled = false
    }
    private let hourlyRadioButton = RadioButtonView(title: "시급", type: .none(selectedRadioButton: .selectedRadioButton, unselectedRadioButton: .unselectedRadioButton))
    private let fixedRadioButton = RadioButtonView(title: "고정급", type: .none(selectedRadioButton: .selectedRadioButton, unselectedRadioButton: .unselectedRadioButton))
    
    // MARK: - Getter
    var getHourlyRadioButton: RadioButtonView { hourlyRadioButton }
    var getFixedRadioButton: RadioButtonView { fixedRadioButton }
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

private extension SelectPayCalculationView {
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
            hourlyRadioButton,
            fixedRadioButton,
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
        
        hourlyRadioButton.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        fixedRadioButton.snp.makeConstraints {
            $0.top.equalTo(hourlyRadioButton.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        registerButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(45)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(12)
        }
    }
}

extension Reactive where Base: SelectPayCalculationView {
    var navBackBtnTapped: ControlEvent<Void> {
        return base.navigationBar.rx.backBtnTapped
    }
}
