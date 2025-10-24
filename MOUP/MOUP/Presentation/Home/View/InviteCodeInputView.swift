//
//  InviteCodeInputView.swift
//  MOUP
//
//  Created by 송규섭 on 10/18/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class InviteCodeInputView: UIView {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    fileprivate let navigationBar = BaseNavigationBar(title: "새 근무지")
    
    private let commentLabel = UILabel().then {
        $0.text = "초대 코드를 입력해주세요"
        $0.textColor = .gray900
        $0.font = .headBold(18)
    }
    
    fileprivate let codeInputTextField = UITextField().then {
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        $0.leftView = leftView
        $0.leftViewMode = .always
        $0.rightView = rightView
        $0.defaultTextAttributes = [
            .font: UIFont.fieldsRegular(16),
            .foregroundColor: UIColor.gray900
        ]
        $0.layer.borderColor = UIColor.gray400.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 12
    }
    
    fileprivate let searchButton = BaseButton(title: "조회하기", isSecondary: false).then {
        $0.isEnabled = false
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
    func setTextFieldDelegate(_ delegate: UITextFieldDelegate) {
        self.codeInputTextField.delegate = delegate
    }
}

private extension InviteCodeInputView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setBindings()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            navigationBar,
            commentLabel,
            codeInputTextField,
            searchButton
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        codeInputTextField.attributedPlaceholder = NSAttributedString(
            string: "초대 코드",
            attributes: [
                .font: UIFont.fieldsRegular(16),
                .foregroundColor: UIColor.gray400
            ]
        )
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalToSuperview()
        }
        
        commentLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(32)
            $0.leading.equalToSuperview().inset(16)
        }
        
        codeInputTextField.snp.makeConstraints {
            $0.top.equalTo(commentLabel.snp.bottom).offset(24)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }
        
        searchButton.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(keyboardLayoutGuide.snp.top).offset(-12)
            $0.height.equalTo(45)
        }
    }
    
    func setBindings() {
        codeInputTextField.rx.text.orEmpty
            .withUnretained(self)
            .subscribe(onNext: { owner, text in
                owner.searchButton.isEnabled = !text.isEmpty
            })
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: InviteCodeInputView {
    var navBackBtnTapped: ControlEvent<Void> {
        return base.navigationBar.rx.backBtnTapped
    }
    
    var searchBtnTapped: ControlEvent<String> { // 버튼이 눌린 시점 텍스트필드의 값을 스트림으로 보냄
        let source = base.searchButton.rx.tap
            .withLatestFrom(base.codeInputTextField.rx.text.orEmpty)
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            
        return ControlEvent(events: source)
    }
    
}
