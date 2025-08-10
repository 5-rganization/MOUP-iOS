//
//  NicknameView.swift
//  MOUP
//
//  Created by 송규섭 on 8/10/25.
//

import UIKit

final class NicknameView: UIView {
    // MARK: - Properties

    // MARK: - UI Components

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

private extension NicknameView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }

    // MARK: - setHierarchy
    func setHierarchy() {

    }

    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .primaryBackground
    }

    // MARK: - setConstraints
    func setConstraints() {

    }
}

