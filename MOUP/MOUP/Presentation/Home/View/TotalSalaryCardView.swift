//
//  TotalSalaryCardView.swift
//  MOUP
//
//  Created by 송규섭 on 7/22/25.
//

import UIKit

class TotalSalaryCardView: CardView {
    // MARK: - UI Components
    private let containerView = UIView().then {
        $0.clipsToBounds = true
        $0.backgroundColor = .white
    }
    private let logoImageView = UIImageView().then {
        $0.image = .logoIcon
        $0.alpha = 0.14
        $0.contentMode = .scaleAspectFit
    }
    private let gradientLayer = CAGradientLayer()

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: .zero)

        configure()
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - LayoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = containerView.bounds
        gradientLayer.cornerRadius = 12

        containerView.layer.insertSublayer(gradientLayer, at: 0)
    }

}

private extension TotalSalaryCardView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }

    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(containerView)
        containerView.addSubviews(logoImageView)
    }

    // MARK: - setStyles
    func setStyles() {
        gradientLayer.colors = [UIColor.primary50.cgColor, UIColor.primary100.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)

        logoImageView.transform = CGAffineTransform(rotationAngle: CGFloat(-33.68 * .pi / 180))
    }

    // MARK: - setConstraints
    func setConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        logoImageView.snp.makeConstraints {
            $0.centerX.equalTo(containerView.snp.trailing).inset(62)
            $0.centerY.equalTo(containerView.snp.bottom).inset(46)
            $0.size.equalTo(186.98)
        }
    }
}
