//
//  WorkplaceRegisterView.swift
//  MOUP
//
//  Created by 양원식 on 7/15/25.
//

import UIKit
import SnapKit
import Then

final class WorkplaceRegisterView: UIView {
    
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .fill
        $0.distribution = .fill
    }
    
    // MARK: - 컨테이너
    private let workplaceContainerView = WorkplaceContainerView()
    private let payContainerView = PayContainerView()
    
    // MARK: - UI Components
    private let registerButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.title = "등록하기"
        config.baseBackgroundColor = .gray300
        config.baseForegroundColor = .gray500
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0)
        
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var updated = incoming
            updated.font = .buttonSemibold(18)
            return updated
        }
        
        $0.configuration = config
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
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

private extension WorkplaceRegisterView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            scrollView
        )
        
        scrollView.addSubviews(
            contentView
        )
        
        contentView.addSubviews(
            stackView
        )
        
        stackView.addArrangedSubviews(
            workplaceContainerView,
            payContainerView,
            registerButton
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(16)
        }
    }
}

