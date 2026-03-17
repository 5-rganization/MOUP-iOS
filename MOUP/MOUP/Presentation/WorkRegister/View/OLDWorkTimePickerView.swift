//
//  OLDWorkTimePickerView.swift
//  MOUP
//
//  Created by 양원식 on 8/13/25.
//

import UIKit
import SnapKit
import Then

final class OLDWorkTimePickerView: UIView {

    // MARK: - UI
    private let indicatorBar = UIView().then {
        $0.backgroundColor = .gray300
        $0.layer.cornerRadius = 2
    }

    private let pickerView = UIPickerView().then {
        $0.backgroundColor = .clear
    }

    private let cancelButton = BaseButton(title: "취소", isSecondary: true)
    private let confirmButton = BaseButton(title: "선택")

    private let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.distribution = .fillEqually
    }

    // MARK: - Getter
    var getPickerView: UIPickerView { pickerView }
    var getCancelButton: BaseButton { cancelButton }
    var getConfirmButton: BaseButton { confirmButton }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented.") }
}

private extension OLDWorkTimePickerView {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }

    func setHierarchy() {
        addSubviews(indicatorBar, pickerView, buttonStackView)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(confirmButton)
    }

    func setStyles() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
    }

    func setConstraints() {
        indicatorBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(40)
            $0.height.equalTo(4)
        }
        pickerView.snp.makeConstraints {
            $0.top.equalTo(indicatorBar.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(180)
        }
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(pickerView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(16)
            $0.height.equalTo(48)
        }
    }
}
