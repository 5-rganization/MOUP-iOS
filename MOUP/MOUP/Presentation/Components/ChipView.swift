//
//  ChipView.swift
//  MOUP
//
//  Created by 송규섭 on 7/21/25.
//

import UIKit

final class ChipView: UIView {
    // MARK: - Properties
    private let title: String

    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.textColor = .primary600
        $0.font = .fieldsRegular(12)
    }

    // MARK: - Initializer
    init(title: String) {
        self.title = title
        super.init(frame: .zero)

        configure()
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - Public Methods
    func updateTitleLabel(fontSize: CGFloat = 12, color: UIColor = .primary600) {
        titleLabel.font = .fieldsRegular(fontSize)
        titleLabel.textColor = color
    }

    func updateBackgroundColor(color: UIColor) {
        backgroundColor = color
    }
}

private extension ChipView {
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

        titleLabel.text = title
    }

    // MARK: - setConstraints
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        self.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalTo(titleLabel).inset(-8)
            $0.directionalVerticalEdges.equalTo(titleLabel).inset(-2)
        }
    }
}

