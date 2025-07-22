//
//  HomeView.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import UIKit

final class HomeView: UIView {
    // MARK: - Properties

    // MARK: - UI Components
    private let topBar = UIView()
    private let gradient: CAGradientLayer = CAGradientLayer()

    private let logoImageView = UIImageView().then {
        $0.image = .homeAppTitle
    }

//    private let refreshButton = UIButton().then {
//        $0.setImage(.refreshButton, for: .normal)
//        $0.tintColor = .gray700
//    }

    private let refreshButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 13.75, leading: 12.98, bottom: 13.75, trailing: 12.98)
        config.image = UIImage.refreshButton
        $0.configuration = config
    }

    private let totalSalaryCardView = TotalSalaryCardView()
    private let cardLogoImageView = UIImageView().then {
        $0.image = .logoIcon
        $0.alpha = 0.14
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

private extension HomeView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }

    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(topBar, totalSalaryCardView)
        totalSalaryCardView.addSubviews(cardLogoImageView)
        topBar.addSubviews(logoImageView, refreshButton)
    }

    // MARK: - setStyles
    func setStyles() {
        
    }

    // MARK: - setConstraints
    func setConstraints() {
        topBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.height.equalTo(50)
        }

        logoImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(75)
            $0.height.equalTo(32)
        }

        refreshButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(44)
        }

        totalSalaryCardView.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.top.equalTo(topBar.snp.bottom).offset(12)
            $0.height.equalTo(150)
        }
    }
}

