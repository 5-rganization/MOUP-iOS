//
//  UserRoleView.swift
//  MOUP
//
//  Created by 송규섭 on 8/10/25.
//

import UIKit
import RxSwift
import RxCocoa

final class UserRoleView: UIView {
    // MARK: - Properties
    fileprivate let selectedRole = BehaviorSubject<UserRole?>(value: nil)
    private let disposeBag = DisposeBag()

    // MARK: - UI Components
    private let mentLabel = UILabel().then {
        $0.font = .headBold(18)
        $0.textColor = .gray900
        $0.text = "어떤 역할로 시작하시겠어요?"
    }

    private let roleButtonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 19
    }

    private let ownerButton = UserRoleCardButton(userRole: .owner)

    private let workerButton = UserRoleCardButton(userRole: .worker)

    fileprivate let startButton = BaseButton(title: "시작하기", isSecondary: false).then {
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
}

private extension UserRoleView {
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
            mentLabel,
            roleButtonStackView,
            startButton
        )

        roleButtonStackView.addArrangedSubviews(
            ownerButton,
            workerButton
        )
    }

    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .primaryBackground


    }

    // MARK: - setConstraints
    func setConstraints() {
        mentLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).inset(159)
            $0.centerX.equalToSuperview()
        }

        roleButtonStackView.snp.makeConstraints {
            $0.top.equalTo(mentLabel.snp.bottom).offset(32)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(226)
        }

        startButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(12)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(45)
        }
    }

    func setBindings() {
        ownerButton.rx.tap.subscribe(onNext: {
            self.setUserRoleState(role: .owner)
            self.selectedRole.onNext(.owner)
        })
        .disposed(by: disposeBag)

        workerButton.rx.tap.subscribe(onNext: {
            self.setUserRoleState(role: .worker)
            self.selectedRole.onNext(.worker)
        })
        .disposed(by: disposeBag)
    }

}

// MARK: - additional private methods
private extension UserRoleView {
    func setUserRoleState(role: UserRole) {
        startButton.isEnabled = true

        switch role {
        case .owner:
            ownerButton.updateButton(isSelected: true)
            workerButton.updateButton(isSelected: false)
        case .worker:
            ownerButton.updateButton(isSelected: false)
            workerButton.updateButton(isSelected: true)
        }


    }
}

extension Reactive where Base: UserRoleView {
    var selectedRole: Observable<UserRole?> {
        return base.selectedRole.asObservable()
    }

    var startButtonTap: ControlEvent<Void> {
        return base.startButton.rx.tap
    }
}
