//
//  InputSalaryTypeView.swift
//  MOUP
//
//  Created by 양원식 on 7/25/25.
//

import UIKit
import SnapKit
import Then
import RxSwift

final class InputSalaryTypeView: UIView {
    // MARK: - Properties
    
    // MARK: - UI Components
    private let title = UILabel().then {
        $0.text = "시급을 입력해주세요."
        $0.textColor = .gray900
        $0.font = .headBold(18)
    }
    
    private let textField = CustomTextField().then {
        $0.placeholder = "10,030원"
        $0.returnKeyType = .done
    }
    
    private let registerButton = BaseButton(title: "완료", isSecondary: true)
    
    // MARK: - Getter
    var getTitle: UILabel { title }
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
    func updateTitle(_ text: String) {
        title.text = text
    }
    
    func updatePlaceholder(_ placeholder: String) {
        textField.placeholder = placeholder
    }

}

private extension InputSalaryTypeView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
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
        title.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(32)
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
extension Reactive where Base: InputSalaryTypeView {
    /// 타이틀 텍스트를 바인딩하는 Binder
    var titleText: Binder<String> {
        return Binder(base) { view, text in
            view.updateTitle(text)
        }
    }
    
    var placeholderText: Binder<String> {
        Binder(base) { view, text in
            view.updatePlaceholder(text)
        }
    }
}
