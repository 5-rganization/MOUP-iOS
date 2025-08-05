//
//  YearMonthPickerView.swift
//  MOUP
//
//  Created by 서동환 on 7/26/25.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

final class YearMonthPickerView: UIView {
    
    // MARK: - UI Components
    /// 모달 핸들 UI
    private let grabberView = ModalGrabberView()
    /// 이동할 연/월을 선택하는 UI
    private let pickerView = UIPickerView().then {
        $0.backgroundColor = .primaryBackground
    }
    /// 연/월 선택 이동 취소 버튼
    fileprivate let cancelButton = BaseButton(title: "취소", isSecondary: true)
    /// 연/월 선택 이동 버튼
    fileprivate let gotoButton = BaseButton(title: "이동")
    /// 버튼들을 담는 수평 컨테이너
    private let buttonHStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.distribution = .fillEqually
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
}

private extension YearMonthPickerView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        self.addSubviews(grabberView,
                         pickerView,
                         buttonHStackView)
        
        buttonHStackView.addArrangedSubviews(cancelButton, gotoButton)
    }
    
    // MARK: - setStyles
    func setStyles() {
        self.backgroundColor = .primaryBackground
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        grabberView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.centerX.equalTo(self.safeAreaLayoutGuide)
            $0.width.equalTo(45)
            $0.height.equalTo(4)
        }
        
        pickerView.snp.makeConstraints {
            $0.top.equalTo(grabberView).offset(16)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            $0.bottom.equalTo(buttonHStackView.snp.top).offset(-12)
        }
        
        buttonHStackView.snp.makeConstraints {
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide).inset(16)
            $0.bottom.equalTo(self.safeAreaLayoutGuide)
            $0.height.equalTo(44)
        }
    }
}

// MARK: - Extension Reactive
extension Reactive where Base: YearMonthPickerView {
    var cancelButtonTap: ControlEvent<Void> { base.cancelButton.rx.tap }
    var gotoButtonTap: ControlEvent<Void> { base.gotoButton.rx.tap }
}

// MARK: - Getter
extension YearMonthPickerView {
    var getPickerView: UIPickerView { pickerView }
}
