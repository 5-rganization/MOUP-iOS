//
//  RoleConfirmationView.swift
//  MOUP
//
//  Created by 송규섭 on 9/3/25.
//

import UIKit
import RxSwift
import RxCocoa

final class RoleConfirmationView: UIView {
    // MARK: - Properties
    private let disposeBag = DisposeBag()

    // MARK: - UI Components
    private let containerView = UIView().then {
        $0.backgroundColor = .primaryBackground
        $0.layer.cornerRadius = 12
    }

    private let titleLabel = UILabel().then {
        $0.font = .headBold(18)
        $0.textColor = .gray900
        $0.text = ""
    }

    private let contentLabel = UILabel().then {
        $0.font = .bodyMedium(14)
        $0.textColor = .gray700
        $0.numberOfLines = 2
        $0.text = "역할 선택은 한 번만 가능합니다.\n선택 후에는 변경이 불가하니 신중하게 선택해 주세요!"
    }

    private let buttonStackView = UIStackView().then {
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
    func update(by userRole: UserRole) {
        titleLabel.text = userRole == .worker ? "알바생이신가요?" : "사장님이신가요?"
    }
}

private extension RoleConfirmationView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }

    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(containerView)

        containerView.addSubviews(
            titleLabel,
            contentLabel,
            buttonStackView
        )

        buttonStackView.addArrangedSubviews(
            cancelButton,
            confirmButton
        )
    }

    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .gray900.withAlphaComponent(0.5)
    }

    // MARK: - setConstraints
    func setConstraints() {
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(327)
            $0.height.equalTo(210)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
        }

        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.directionalHorizontalEdges.equalTo(titleLabel)
        }

        buttonStackView.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalTo(titleLabel)
            $0.bottom.equalToSuperview().inset(20)
            $0.height.equalTo(45)
        }
    }
}

extension Reactive where Base: RoleConfirmationView {
    var confirmButtonTap: ControlEvent<Void> {
        base.confirmButton.rx.tap
    }

    var cancelButtonTap: ControlEvent<Void> {
        base.cancelButton.rx.tap
    }
}
