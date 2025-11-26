//
//  InputNameView.swift
//  MOUP
//
//  Created by 양원식 on 7/25/25.
//
import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

final class InputNameView: UIView {
    // MARK: - Properties
    
    // MARK: - UI Components
    fileprivate let navigationBar = BaseNavigationBar(title: "근무지 입력")
    
    private let title = UILabel().then {
        $0.text = "근무지 이름을 입력해주세요."
        $0.textColor = .gray900
        $0.font = .headBold(18)
    }
    
    private let textField = CustomTextField().then {
        $0.placeholder = "근무지 명"
        $0.returnKeyType = .done
    }
    
    private let registerButton = BaseButton(title: "완료", isSecondary: true)
    
    // MARK: - Getter
    var getTextField: CustomTextField { textField }
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

private extension InputNameView {
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
            textField,
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
        textField.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(18)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        registerButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(45)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(12)
        }
    }
}

extension Reactive where Base: InputNameView {
    var navBackBtnTapped: ControlEvent<Void> {
        return base.navigationBar.rx.backBtnTapped
    }
}
