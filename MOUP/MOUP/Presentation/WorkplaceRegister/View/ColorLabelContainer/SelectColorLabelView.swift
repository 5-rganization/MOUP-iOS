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
    
    private let confirmButton = BaseButton(title: "완료").then {
        $0.isEnabled = false
    }
    private let redRadioButton = RadioButtonView(title: LabelColor.red.displayStr,
                                                 type: .colorDot(LabelColor.red.labelColor,
                                                                 selectedRadioButton: .selectedRadioButton,
                                                                 unselectedRadioButton: .unselectedRadioButton))
    private let orangeRadioButton = RadioButtonView(title: LabelColor.orange.displayStr,
                                                    type: .colorDot(LabelColor.orange.labelColor,
                                                                    selectedRadioButton: .selectedRadioButton,
                                                                    unselectedRadioButton: .unselectedRadioButton))
    private let yellowRadioButton = RadioButtonView(title: LabelColor.yellow.displayStr,
                                                    type: .colorDot(LabelColor.yellow.labelColor,
                                                                    selectedRadioButton: .selectedRadioButton,
                                                                    unselectedRadioButton: .unselectedRadioButton))
    private let greenRadioButton = RadioButtonView(title: LabelColor.green.displayStr,
                                                   type: .colorDot(LabelColor.green.labelColor,
                                                                   selectedRadioButton: .selectedRadioButton,
                                                                   unselectedRadioButton: .unselectedRadioButton))
    private let blueRadioButton = RadioButtonView(title: LabelColor.blue.displayStr,
                                                  type: .colorDot(LabelColor.blue.labelColor,
                                                                  selectedRadioButton: .selectedRadioButton,
                                                                  unselectedRadioButton: .unselectedRadioButton))
    private let purpleRadioButton = RadioButtonView(title: LabelColor.purple.displayStr,
                                                    type: .colorDot(LabelColor.purple.labelColor,
                                                                    selectedRadioButton: .selectedRadioButton,
                                                                    unselectedRadioButton: .unselectedRadioButton))
    private let indigoRadioButton = RadioButtonView(title: LabelColor.indigo.displayStr,
                                                    type: .colorDot(LabelColor.indigo.labelColor,
                                                                    selectedRadioButton: .selectedRadioButton,
                                                                    unselectedRadioButton: .unselectedRadioButton))
    
    // MARK: - Getter
    var getRedRadioButton: RadioButtonView { redRadioButton }
    var getOrangeRadioButton: RadioButtonView { orangeRadioButton }
    var getYellowRadioButton: RadioButtonView { yellowRadioButton }
    var getGreenRadioButton: RadioButtonView { greenRadioButton }
    var getBlueRadioButton: RadioButtonView { blueRadioButton }
    var getPurpleRadioButton: RadioButtonView { purpleRadioButton }
    var getIndigoRadioButton: RadioButtonView { indigoRadioButton }
    var getConfirmButton: BaseButton { confirmButton }
    
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
            confirmButton
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
        
        confirmButton.snp.makeConstraints {
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
