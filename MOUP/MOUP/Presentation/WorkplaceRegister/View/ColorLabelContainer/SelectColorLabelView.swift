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
import Then

final class SelectColorLabelView: UIView {
    // MARK: - Properties
    
    // MARK: - UI Components
    fileprivate let navigationBar = BaseNavigationBar(title: "라벨 색상")
    
    private let title = UILabel().then {
        $0.text = "라벨 색상을 선택해주세요."
        $0.textColor = .gray900
        $0.font = .headBold(18)
    }
    
    private let registerButton = BaseButton(title: "완료", isSecondary: true)
    private let redRadioButton = RadioButtonView(title: "빨강색", type: .colorDot(.labelRed, selectedRadioButton: UIImage(named: "selectedRadioButton")!, unselectedRadioButton: UIImage(named: "unselectedRadioButton")!))
    private let orangeRadioButton = RadioButtonView(title: "주황색", type: .colorDot(.labelOrange, selectedRadioButton: UIImage(named: "selectedRadioButton")!, unselectedRadioButton: UIImage(named: "unselectedRadioButton")!))
    private let yellowRadioButton = RadioButtonView(title: "노란색", type: .colorDot(.labelYellow, selectedRadioButton: UIImage(named: "selectedRadioButton")!, unselectedRadioButton: UIImage(named: "unselectedRadioButton")!))
    private let greenRadioButton = RadioButtonView(title: "초록색", type: .colorDot(.labelGreen, selectedRadioButton: UIImage(named: "selectedRadioButton")!, unselectedRadioButton: UIImage(named: "unselectedRadioButton")!))
    private let blueRadioButton = RadioButtonView(title: "파란색", type: .colorDot(.labelBlue, selectedRadioButton: UIImage(named: "selectedRadioButton")!, unselectedRadioButton: UIImage(named: "unselectedRadioButton")!))
    private let purpleRadioButton = RadioButtonView(title: "보라색", type: .colorDot(.labelPurple, selectedRadioButton: UIImage(named: "selectedRadioButton")!, unselectedRadioButton: UIImage(named: "unselectedRadioButton")!))
    private let indigoRadioButton = RadioButtonView(title: "남색", type: .colorDot(.indigoText, selectedRadioButton: UIImage(named: "selectedRadioButton")!, unselectedRadioButton: UIImage(named: "unselectedRadioButton")!))
    
    // MARK: - Getter
    var getRedRadioButton: RadioButtonView { redRadioButton }
    var getOrangeRadioButton: RadioButtonView { orangeRadioButton }
    var getYellowRadioButton: RadioButtonView { yellowRadioButton }
    var getGreenRadioButton: RadioButtonView { greenRadioButton }
    var getBlueRadioButton: RadioButtonView { blueRadioButton }
    var getPurpleRadioButton: RadioButtonView { purpleRadioButton }
    var getIndigoRadioButton: RadioButtonView { indigoRadioButton }
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

private extension SelectColorLabelView {
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
            redRadioButton,
            orangeRadioButton,
            yellowRadioButton,
            greenRadioButton,
            blueRadioButton,
            purpleRadioButton,
            indigoRadioButton,
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
            $0.top.equalTo(navigationBar).offset(32)
            $0.leading.equalToSuperview().offset(16)
        }
        
        redRadioButton.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        orangeRadioButton.snp.makeConstraints {
            $0.top.equalTo(redRadioButton.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        yellowRadioButton.snp.makeConstraints {
            $0.top.equalTo(orangeRadioButton.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        greenRadioButton.snp.makeConstraints {
            $0.top.equalTo(yellowRadioButton.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        blueRadioButton.snp.makeConstraints {
            $0.top.equalTo(greenRadioButton.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        indigoRadioButton.snp.makeConstraints {
            $0.top.equalTo(blueRadioButton.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        purpleRadioButton.snp.makeConstraints {
            $0.top.equalTo(indigoRadioButton.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        registerButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(45)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(12)
        }
    }
}

extension Reactive where Base: SelectColorLabelView {
    var navBackBtnTapped: ControlEvent<Void> {
        return base.navigationBar.rx.backBtnTapped
    }
}
