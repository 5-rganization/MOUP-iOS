//
//  WorkplaceContainerView.swift
//  MOUP
//
//  Created by 양원식 on 7/16/25.
//

import UIKit
import SnapKit
import Then

final class WorkplaceContainerView: UIView {
    // MARK: - Properties
    private let container = ContainerView()
    
    // MARK: - 이름 레이블
    private let nameRow = InfoRowView(title: "이름", type: .labelWithChevron(value: "근무지 이름"), frame: .zero)
    
    // MARK: - 카테고리 레이블
    private let categoryRow = InfoRowView(title: "카테고리", type: .labelWithChevron(value: "선택"), frame: .zero)
    
    // MARK: - UI Components
    // 디바이더
    private let divider = UIView().then {
        $0.backgroundColor = .gray400
    }
    
    // MARK: - 근무지 타이틀
    private let workplaceTitle = UILabel().then {
        let fullText = "근무지 *"
        let attributed = NSMutableAttributedString(string: fullText)

        attributed.addAttribute(.font, value: UIFont.headBold(18), range: NSRange(location: 0, length: fullText.count))
        attributed.addAttribute(.foregroundColor, value: UIColor.gray900, range: NSRange(location: 0, length: fullText.count))

        if let starRange = fullText.range(of: "*") {
            let nsRange = NSRange(starRange, in: fullText)
            attributed.addAttribute(.foregroundColor, value: UIColor.accent, range: nsRange)
        }

        $0.attributedText = attributed
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

private extension WorkplaceContainerView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            workplaceTitle,
            container
        )
        
        container.addSubviews(
            nameRow,
            divider,
            categoryRow
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        
        // MARK: - 근무지 타이틀
        workplaceTitle.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
        }
        
        // MARK: - 컨테이너
        container.snp.makeConstraints {
            $0.top.equalTo(workplaceTitle.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(categoryRow.snp.bottom)
        }
        
        // MARK: - 이름
        nameRow.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }
        
        divider.snp.makeConstraints {
            $0.top.equalTo(nameRow.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        // MARK: - 카테고리
        categoryRow.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
        }
        
        self.snp.makeConstraints {
            $0.bottom.equalTo(container.snp.bottom).offset(0)
        }
    }
}

