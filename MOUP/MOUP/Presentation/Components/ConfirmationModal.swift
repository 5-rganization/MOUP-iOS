//
//  ConfirmationModal.swift
//  MOUP
//
//  Created by 송규섭 on 10/2/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class ConfirmationModal: UIView {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = .headBold(18)
        $0.textAlignment = .left
    }
    
    private let commentLabel = UILabel().then {
        $0.textColor = .gray700
        $0.numberOfLines = 2
        $0.textAlignment = .left
        $0.font = .bodyMedium(14)
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
    }
    
    fileprivate let cancelButton = BaseButton(title: "아니요", isSecondary: true)
    fileprivate let confirmButton = BaseButton(title: "네", isSecondary: false)
    
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
    func update(title: String, comment: String) {
        titleLabel.text = title
        commentLabel.text = comment
    }
}

private extension ConfirmationModal {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            titleLabel,
            commentLabel,
            stackView
        )
        
        stackView.addArrangedSubviews(
            cancelButton,
            confirmButton
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .primaryBackground
        self.layer.cornerRadius = 12
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        self.snp.makeConstraints {
            $0.width.equalTo(327)
            $0.height.equalTo(210)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
        }
        
        commentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
        }
        
        stackView.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(20)
            $0.height.equalTo(45)
        }
    }
}

extension Reactive where Base: ConfirmationModal {
    var cancelBtnTapped: ControlEvent<Void> {
        return base.cancelButton.rx.tap
    }
    
    var confirmBtnTapped: ControlEvent<Void> {
        return base.confirmButton.rx.tap
    }
}
