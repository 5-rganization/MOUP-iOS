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
    
    // 근무지 컨테이너
    private let workplaceContainerView = WorkplaceContainerView()
    
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
            workplaceContainerView
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        workplaceContainerView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(32)
            $0.horizontalEdges.equalToSuperview()
        }
    }
}

