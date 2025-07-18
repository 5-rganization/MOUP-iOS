//
//  WageContainerView.swift
//  MOUP
//
//  Created by 양원식 on 7/17/25.
//

import UIKit
import SnapKit
import Then

final class PayContainerView: UIView {
    // MARK: - Properties
    private let container = ContainerView()
    
    // MARK: - UI Components
    
    // 디바이더
    private let divider1 = UIView().then {
        $0.backgroundColor = .gray400
    }
    
    private let divider2 = UIView().then {
        $0.backgroundColor = .gray400
    }
    
    private let divider3 = UIView().then {
        $0.backgroundColor = .gray400
    }
    
    // MARK: - 급여 타이틀
    private let payTitle = UILabel().then {
        let fullText = "급여 *"
        let attributed = NSMutableAttributedString(string: fullText)

        attributed.addAttribute(.font, value: UIFont.headBold(18), range: NSRange(location: 0, length: fullText.count))
        attributed.addAttribute(.foregroundColor, value: UIColor.gray900, range: NSRange(location: 0, length: fullText.count))

        if let starRange = fullText.range(of: "*") {
            let nsRange = NSRange(starRange, in: fullText)
            attributed.addAttribute(.foregroundColor, value: UIColor.accent, range: nsRange)
        }

        $0.attributedText = attributed
    }
    
    // MARK: - 급여 유형 레이블
    private let payTypeLabel = UILabel().then {
        $0.text = "급여 유형"
        $0.textColor = .gray900
        $0.font = .bodyMedium(16)
    }
    
    private let payTypeValueLabel = UILabel().then {
        $0.text = "선택"
        $0.textColor = .gray700
        $0.font = .bodyMedium(16)
    }
    
    private let payTypeChevron = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = .gray400
    }
    
    // MARK: - 급여 계산 레이블
    private let payCalculationLabel = UILabel().then {
        $0.text = "급여 계산"
        $0.textColor = .gray900
        $0.font = .bodyMedium(16)
    }
    
    private let payCalculationValueLabel = UILabel().then {
        $0.text = "선택"
        $0.textColor = .gray700
        $0.font = .bodyMedium(16)
    }
    
    private let payCalculationChevron = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = .gray400
    }
    
    // MARK: - 급여 형태 레이블
    private let salaryTypeLabel = UILabel().then {
        $0.text = "급여 형태"
        $0.textColor = .gray900
        $0.font = .bodyMedium(16)
    }
    
    private let salaryTypeValueLabel = UILabel().then {
        $0.text = "선택"
        $0.textColor = .gray700
        $0.font = .bodyMedium(16)
    }
    
    private let salaryTypeChevron = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = .gray400
    }
    
    // MARK: - 급여일 레이블
    private let payDayLabel = UILabel().then {
        $0.text = "급여일"
        $0.textColor = .gray900
        $0.font = .bodyMedium(16)
    }
    
    private let payDayValueButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.title = "선택"
        config.baseBackgroundColor = .primary100
        config.baseForegroundColor = .gray700
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var updated = incoming
            updated.font = .bodyMedium(16)
            return updated
        }
        
        $0.configuration = config
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
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

private extension PayContainerView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            payTitle,
            container
        )
        
        container.addSubviews(
            divider1,
            divider2,
            divider3,
            payTypeLabel,
            payTypeValueLabel,
            payTypeChevron,
            payCalculationLabel,
            payCalculationValueLabel,
            payCalculationChevron,
            salaryTypeLabel,
            salaryTypeValueLabel,
            salaryTypeChevron,
            payDayLabel,
            payDayValueButton
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        
        // MARK: - 급여 타이틀
        payTitle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(16)
        }
        
        // MARK: - 컨테이너
        container.snp.makeConstraints {
            $0.top.equalTo(payTitle.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(payDayLabel.snp.bottom).offset(12)
        }
        
        // MARK: - 급여 유형
        payTypeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(16)
        }
        
        payTypeValueLabel.snp.makeConstraints {
            $0.centerY.equalTo(payTypeLabel)
            $0.trailing.equalTo(payTypeChevron.snp.leading).offset(-12)
        }
        
        payTypeChevron.snp.makeConstraints {
            $0.centerY.equalTo(payTypeLabel)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        divider1.snp.makeConstraints {
            $0.top.equalTo(payTypeLabel.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        // MARK: - 급여 계산
        payCalculationLabel.snp.makeConstraints {
            $0.top.equalTo(divider1.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(16)
        }
        
        payCalculationValueLabel.snp.makeConstraints {
            $0.centerY.equalTo(payCalculationLabel)
            $0.trailing.equalTo(payCalculationChevron.snp.leading).offset(-12)
        }
        
        payCalculationChevron.snp.makeConstraints {
            $0.centerY.equalTo(payCalculationLabel)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        divider2.snp.makeConstraints {
            $0.top.equalTo(payCalculationLabel.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        // MARK: - 급여형태
        salaryTypeLabel.snp.makeConstraints {
            $0.top.equalTo(divider2.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(16)
        }
        
        salaryTypeValueLabel.snp.makeConstraints {
            $0.centerY.equalTo(salaryTypeLabel)
            $0.trailing.equalTo(salaryTypeChevron.snp.leading).offset(-12)
        }
        
        salaryTypeChevron.snp.makeConstraints {
            $0.centerY.equalTo(salaryTypeLabel)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        divider3.snp.makeConstraints {
            $0.top.equalTo(salaryTypeLabel.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        // MARK: - 급여일
        payDayLabel.snp.makeConstraints {
            $0.top.equalTo(divider3.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(16)
        }
        
        payDayValueButton.snp.makeConstraints {
            $0.centerY.equalTo(payDayLabel)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        self.snp.makeConstraints {
            $0.bottom.equalTo(container.snp.bottom).offset(0)
        }
    }
}

