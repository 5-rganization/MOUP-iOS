//
//  UserRoleCardButton.swift
//  MOUP
//
//  Created by 송규섭 on 8/10/25.
//

import UIKit

class UserRoleCardButton: UIButton {
    // MARK: - Properties
    private let userRole: UserRole

    // MARK: - UI Components
    private let userRoleImageView = UIImageView()
    private let userRoleTitleLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray700
    }

    // MARK: - Initializer
    init(userRole: UserRole) {
        self.userRole = userRole
        super.init(frame: .zero)
        configure()
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - Public Methods
    func updateButton(isSelected: Bool) {
        layer.cornerRadius = 12
        layer.borderColor = isSelected ? UIColor.primary500.cgColor : UIColor.gray400.cgColor
        layer.borderWidth = isSelected ? 2 : 1.5
        layer.shadowColor = isSelected ? UIColor.primary500.cgColor : .none
        layer.shadowOpacity = isSelected ? 0.7 : 0
        layer.shadowOffset = isSelected ? CGSize(width: 0, height: 1) : CGSize()
        layer.shadowRadius = isSelected ? 8 / 2.0 : 0 // 피그마 상에서의 1/2
    }

}

private extension UserRoleCardButton {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setConstraints()
        setStyles()
    }

    func setHierarchy() {
        addSubviews(
            userRoleImageView,
            userRoleTitleLabel
        )
    }

    func setConstraints() {
        userRoleImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.centerX.equalToSuperview()
        }

        userRoleTitleLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(20)
            $0.centerX.equalToSuperview()
        }
    }

    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white

        layer.cornerRadius = 12
        layer.borderColor = UIColor.gray400.cgColor
        layer.borderWidth = 1.5

        userRoleTitleLabel.text = userRole == .owner ? "사장님" : "알바생"
        userRoleImageView.image = userRole == .owner ? .owner : .worker
    }
}
