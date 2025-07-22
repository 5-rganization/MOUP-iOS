//
//  CardView.swift
//  MOUP
//
//  Created by 송규섭 on 7/21/25.
//

import UIKit

class CardView: UIView {
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

private extension CardView {
    // MARK: - configure
    func configure() {
        setStyles()
    }

    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white

        layer.masksToBounds = false
        layer.shadowColor = UIColor.gray900.withAlphaComponent(0.1).cgColor
        layer.shadowOpacity = 1.0
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 2.5
        layer.cornerRadius = 12
    }
}

