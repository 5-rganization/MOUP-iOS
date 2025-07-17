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
    
    // MARK: - UI Components
    // 디바이더
    private let divider = UIView().then {
        $0.backgroundColor = .gray400
    }
    
    // 근무지 타이틀
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
    
    // 이름 레이블
    private let nameLabel = UILabel().then {
        $0.text = "이름"
        $0.textColor = .gray900
        $0.font = .bodyMedium(16)
    }
    
    private let nameValueLabel = UILabel().then {
        $0.text = "근무지 이름"
        $0.textColor = .gray700
        $0.font = .bodyMedium(16)
    }
    
    private let nameChevron = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = .gray400
    }
    
    // 카테고리 레이블
    private let categoryLabel = UILabel().then {
        $0.text = "카테고리"
        $0.textColor = .gray900
        $0.font = .bodyMedium(16)
    }
    
    private let categoryValueLabel = UILabel().then {
        $0.text = "선택"
        $0.textColor = .gray700
        $0.font = .bodyMedium(16)
    }
    
    private let categoryChevron = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = .gray400
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
            nameLabel,
            nameValueLabel,
            nameChevron,
            divider,
            categoryLabel,
            categoryValueLabel,
            categoryChevron
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        workplaceTitle.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(32)
            $0.leading.equalToSuperview().offset(16)
        }
        
        container.snp.makeConstraints {
            $0.top.equalTo(workplaceTitle.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(categoryChevron.snp.bottom).offset(16)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(16)
        }
        
        nameValueLabel.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel)
            $0.trailing.equalTo(nameChevron.snp.leading).offset(-12)
        }
        
        nameChevron.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        divider.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        categoryLabel.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(16)
        }
        
        categoryValueLabel.snp.makeConstraints {
            $0.centerY.equalTo(categoryLabel)
            $0.trailing.equalTo(categoryChevron.snp.leading).offset(-12)
        }
        
        categoryChevron.snp.makeConstraints {
            $0.centerY.equalTo(categoryLabel)
            $0.trailing.equalToSuperview().inset(16)
        }
    }
}

