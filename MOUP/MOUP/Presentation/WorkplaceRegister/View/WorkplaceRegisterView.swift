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
    
    // 근무지 컨테이너
    private let workplaceContainerView = WorkplaceContainerView()
    private let payContainerView = PayContainerView()
    
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
            payContainerView
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

