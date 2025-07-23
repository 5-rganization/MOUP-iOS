//
//  WorkingConditionsContainerView.swift
//  MOUP
//
//  Created by 양원식 on 7/18/25.
//
import UIKit
import SnapKit
import Then

final class WorkingConditionsContainerView: UIView {
    // MARK: - Properties
    private let container = ContainerView()
    
    // MARK: - 4대보험
    private let fourMajorSocialInsurancesInfoRow = InfoRowView(title: "4대 보험", type: .checkBox(isChecked: false), frame: .zero)
    // MARK: - 국민연금
    private let nationalPensionInfoRow = InfoRowView(title: "국민연금", type: .checkBox(isChecked: false), frame: .zero)
    // MARK: - 건강보험
    private let nationalHealthInsuranceInfoRow = InfoRowView(title: "건강보험", type: .checkBox(isChecked: false), frame: .zero)
    // MARK: - 고용보험
    private let employmentInsuranceInfoRow = InfoRowView(title: "고용보험", type: .checkBox(isChecked: false), frame: .zero)
    // MARK: - 산재보험
    private let industrialAccidentCompensationInsuranceInfoRow = InfoRowView(title: "산재보험", type: .checkBox(isChecked: false), frame: .zero)
    // MARK: - 소득세
    private let incomeTaxInfoRow = InfoRowView(title: "소득세", type: .checkBox(isChecked: false), frame: .zero)
    // MARK: - 주휴수당
    private let weeklyHolidayAllowanceInfoRow = InfoRowView(title: "주휴수당", type: .checkBox(isChecked: false), frame: .zero)
    // MARK: - 야간수당
    private let nightShiftAllowanceInfoRow = InfoRowView(title: "야간수당", type: .checkBox(isChecked: false), frame: .zero)
    
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
    
    private let divider4 = UIView().then {
        $0.backgroundColor = .gray400
    }
    
    private let divider5 = UIView().then {
        $0.backgroundColor = .gray400
    }
    
    private let divider6 = UIView().then {
        $0.backgroundColor = .gray400
    }
    
    private let divider7 = UIView().then {
        $0.backgroundColor = .gray400
    }
    
    // MARK: - 근무 조건 타이틀
    private let workplaceTitle = UILabel().then {
        let fullText = "근무 조건 *"
        let attributed = NSMutableAttributedString(string: fullText)

        attributed.addAttribute(.font, value: UIFont.headBold(18), range: NSRange(location: 0, length: fullText.count))
        attributed.addAttribute(.foregroundColor, value: UIColor.gray900, range: NSRange(location: 0, length: fullText.count))

        if let starRange = fullText.range(of: "*") {
            let nsRange = NSRange(starRange, in: fullText)
            attributed.addAttribute(.foregroundColor, value: UIColor.accent, range: nsRange)
        }

        $0.attributedText = attributed
    }
    
    // MARK: - Getter
    var getFourMajorSocialInsurancesInfoRow: InfoRowView { fourMajorSocialInsurancesInfoRow }
    var getNationalPensionInfoRow: InfoRowView { nationalPensionInfoRow }
    var getNationalHealthInsuranceInfoRow: InfoRowView { nationalHealthInsuranceInfoRow }
    var getEmploymentInsuranceInfoRow: InfoRowView { employmentInsuranceInfoRow }
    var getIndustrialAccidentCompensationInsuranceInfoRow: InfoRowView { industrialAccidentCompensationInsuranceInfoRow }
    var getIncomeTaxInfoRow: InfoRowView { incomeTaxInfoRow }
    var getWeeklyHolidayAllowanceInfoRow: InfoRowView { weeklyHolidayAllowanceInfoRow }
    var getNightShiftAllowanceInfoRow: InfoRowView { nightShiftAllowanceInfoRow }
    
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

private extension WorkingConditionsContainerView {
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
            divider1,
            divider2,
            divider3,
            divider4,
            divider5,
            divider6,
            divider7,
            fourMajorSocialInsurancesInfoRow,
            nationalPensionInfoRow,
            nationalHealthInsuranceInfoRow,
            employmentInsuranceInfoRow,
            industrialAccidentCompensationInsuranceInfoRow,
            incomeTaxInfoRow,
            weeklyHolidayAllowanceInfoRow,
            nightShiftAllowanceInfoRow
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        
        // MARK: - 근무 조건 타이틀
        workplaceTitle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(16)
        }
        
        // MARK: - 컨테이너
        container.snp.makeConstraints {
            $0.top.equalTo(workplaceTitle.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(nightShiftAllowanceInfoRow.snp.bottom)
        }

        // MARK: - 4대 보험
        fourMajorSocialInsurancesInfoRow.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }
        
        divider1.snp.makeConstraints {
            $0.top.equalTo(fourMajorSocialInsurancesInfoRow.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        // MARK: - 국민연금
        nationalPensionInfoRow.snp.makeConstraints {
            $0.top.equalTo(divider1.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
        }
        
        divider2.snp.makeConstraints {
            $0.top.equalTo(nationalPensionInfoRow.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }

        // MARK: - 건강보험
        nationalHealthInsuranceInfoRow.snp.makeConstraints {
            $0.top.equalTo(divider2.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
        }

        divider3.snp.makeConstraints {
            $0.top.equalTo(nationalHealthInsuranceInfoRow.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }

        // MARK: - 고용보험
        employmentInsuranceInfoRow.snp.makeConstraints {
            $0.top.equalTo(divider3.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
        }

        divider4.snp.makeConstraints {
            $0.top.equalTo(employmentInsuranceInfoRow.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }

        // MARK: - 산재보험
        industrialAccidentCompensationInsuranceInfoRow.snp.makeConstraints {
            $0.top.equalTo(divider4.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
        }

        divider5.snp.makeConstraints {
            $0.top.equalTo(industrialAccidentCompensationInsuranceInfoRow.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }

        // MARK: - 소득세
        incomeTaxInfoRow.snp.makeConstraints {
            $0.top.equalTo(divider5.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
        }

        divider6.snp.makeConstraints {
            $0.top.equalTo(incomeTaxInfoRow.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }

        // MARK: - 주휴수당
        weeklyHolidayAllowanceInfoRow.snp.makeConstraints {
            $0.top.equalTo(divider6.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
        }

        divider7.snp.makeConstraints {
            $0.top.equalTo(weeklyHolidayAllowanceInfoRow.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }

        // MARK: - 야간수당
        nightShiftAllowanceInfoRow.snp.makeConstraints {
            $0.top.equalTo(divider7.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
        }

        self.snp.makeConstraints {
            $0.bottom.equalTo(container.snp.bottom).offset(0)
        }
    }

}

