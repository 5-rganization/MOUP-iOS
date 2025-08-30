//
//  WorkplaceConnectionChip.swift
//  MOUP
//
//  Created by 송규섭 on 8/29/25.
//

import UIKit

final class WorkplaceOfficialChip: UIView {
    // MARK: - Properties

    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.text = "연동"
        $0.textColor = .primary600
        $0.font = .fieldsRegular(12)
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

private extension WorkplaceOfficialChip {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }

    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(titleLabel)
    }

    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .primary100
        layer.cornerRadius = 10
    }

    // MARK: - setConstraints
    func setConstraints() {
        self.snp.makeConstraints {
            $0.width.equalTo(37)
            $0.height.equalTo(18)
        }

        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

