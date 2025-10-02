//
//  RoleConfirmationView.swift
//  MOUP
//
//  Created by 송규섭 on 9/3/25.
//

import UIKit
import RxSwift
import RxCocoa

final class RoleConfirmationView: UIView { // TODO: - 공용 컴포넌트로 이전 필요
    // MARK: - Properties
    private let disposeBag = DisposeBag()

    // MARK: - UI Components
    fileprivate let confirmationModal = ConfirmationModal()

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
        confirmationModal.update(
            title: userRole == .worker ? "알바생이신가요?" : "사장님이신가요?",
            comment: "역할 선택은 한 번만 가능합니다.\n선택 후에는 변경이 불가하니 신중하게 선택해 주세요!"
        )
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
        addSubviews(confirmationModal)
    }

    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .gray900.withAlphaComponent(0.5)
    }

    // MARK: - setConstraints
    func setConstraints() {
        confirmationModal.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

extension Reactive where Base: RoleConfirmationView {
    var confirmButtonTap: ControlEvent<Void> {
        base.confirmationModal.rx.confirmBtnTapped
    }

    var cancelButtonTap: ControlEvent<Void> {
        base.confirmationModal.rx.cancelBtnTapped
    }
}
