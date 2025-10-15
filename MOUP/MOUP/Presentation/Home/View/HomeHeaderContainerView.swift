//
//  HomeHeaderContainerView.swift
//  MOUP
//
//  Created by 송규섭 on 7/22/25.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeHeaderContainerView: UIView {
    // MARK: - Properties
    private let userRole: UserRole

    // MARK: - UI Components
    
    // 최상단 총 급여 카드뷰
    private let totalSalaryCardView = TotalSalaryCardView().then {
        $0.isUserInteractionEnabled = false
    }
    private let cardLogoImageView = UIImageView().then {
        $0.image = .logoIcon
        $0.alpha = 0.14
    }
    private lazy var summaryTitleLabel = UILabel().then {
        let now = Date()
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: now)
        $0.text = userRole == .worker ? "\(currentMonth)월 총 급여" : "\(currentMonth)월 총 인건비"
        $0.font = .headBold(20)
        $0.textColor = .gray900
        $0.textAlignment = .left
    }
    private let amountLabel = UILabel().then {
        $0.font = .headBold(20)
        $0.textColor = .gray900
        $0.text = "총 금액"
        $0.textAlignment = .right
    }
    private let totalSalaryCardDivider = UIView().then {
        $0.backgroundColor = .gray100
    }
    private let comparisonDescriptionLabel = UILabel().then {
        $0.font = .bodyMedium(14)
        $0.textColor = .gray700
        $0.text = "지난 달과의 비교 금액"
        $0.textAlignment = .right
    }

    // 루틴 관련 컴포넌트
    private let routineSectionTitleLabel = UILabel().then {
        $0.text = "루틴"
        $0.font = .headBold(18)
    }

    private let routineCardStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 12
    }

    // 오늘의 루틴 관련 컴포넌트
    fileprivate let todayRoutineCardView = CardButton().then {
        $0.backgroundColor = .primary50
    }
    private let todayRoutineTitleLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = .bodyMedium(16)
        $0.text = "오늘의 루틴"
    }
    private let todayRoutineRightImageView = UIImageView().then {
        $0.image = .chevronRightForCard
        $0.tintColor = .gray700
    }
    private let todayRoutineCommentLabel = UILabel().then {
        $0.font = .bodyMedium(12)
        $0.textColor = .gray700
        $0.text = "오늘 루틴 총 n개 있어요!"
        $0.textAlignment = .left
    }

    // 모든 루틴 관련 컴포넌트
    fileprivate let allRoutineCardView = CardButton().then {
        $0.backgroundColor = .primary50
    }
    private let allRoutineTitleLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = .bodyMedium(16)
        $0.text = "전체 루틴"
    }
    private let allRoutineRightImageView = UIImageView().then {
        $0.image = .chevronRightForCard
        $0.tintColor = .gray700
    }
    private let allRoutineCommentLabel = UILabel().then {
        $0.font = .bodyMedium(12)
        $0.textColor = .gray700
        $0.text = "모든 루틴을 확인해 보세요!"
        $0.textAlignment = .left
    }

    private let myWorkplaceSectionTitleLabel = UILabel().then {
        $0.text = "나의 근무지"
        $0.font = .headBold(18)
    }

    fileprivate let plusButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        config.image = .plus.withTintColor(.gray700)

        $0.configuration = config
    }

    // MARK: - Initializer
    init(userRole: UserRole) {
        self.userRole = userRole
        super.init(frame: .zero)

        configure()
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - Public Methods
}

private extension HomeHeaderContainerView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }

    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            totalSalaryCardView,
            routineSectionTitleLabel,
            routineCardStackView,
            myWorkplaceSectionTitleLabel,
            plusButton
        )
        routineCardStackView.addArrangedSubviews(
            todayRoutineCardView,
            allRoutineCardView
        )
        totalSalaryCardView.addSubviews(
            cardLogoImageView,
            summaryTitleLabel,
            amountLabel,
            totalSalaryCardDivider,
            comparisonDescriptionLabel
        )
        todayRoutineCardView.addSubviews(
            todayRoutineTitleLabel,
            todayRoutineRightImageView,
            todayRoutineCommentLabel
        )
        allRoutineCardView.addSubviews(
            allRoutineTitleLabel,
            allRoutineRightImageView,
            allRoutineCommentLabel
        )
    }

    // MARK: - setStyles
    func setStyles() {

    }

    // MARK: - setConstraints
    func setConstraints() {
        // 최상단 카드 뷰
        totalSalaryCardView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(121)
        }
        summaryTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
        }
        amountLabel.snp.makeConstraints {
            $0.top.equalTo(summaryTitleLabel.snp.bottom).offset(12)
            $0.directionalHorizontalEdges.equalTo(summaryTitleLabel)
        }
        totalSalaryCardDivider.snp.makeConstraints {
            $0.top.equalTo(amountLabel.snp.bottom).offset(6)
            $0.directionalHorizontalEdges.equalTo(summaryTitleLabel)
            $0.height.equalTo(1)
        }
        comparisonDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(totalSalaryCardDivider.snp.bottom).offset(6)
            $0.directionalHorizontalEdges.equalTo(summaryTitleLabel)
        }

        // 루틴
        routineSectionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(totalSalaryCardView.snp.bottom).offset(20)
            $0.leading.equalTo(totalSalaryCardView.snp.leading)
        }

        routineCardStackView.snp.makeConstraints {
            $0.top.equalTo(routineSectionTitleLabel.snp.bottom).offset(20)
            $0.directionalHorizontalEdges.equalTo(totalSalaryCardView)
            $0.height.equalTo(81)
        }

        // 오늘의 루틴
        todayRoutineTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.equalToSuperview().inset(16)
        }
        todayRoutineRightImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalTo(todayRoutineTitleLabel)
            $0.width.equalTo(7)
            $0.height.equalTo(12)
        }
        todayRoutineCommentLabel.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(12)
        }

        // 오늘의 루틴
        allRoutineTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.equalToSuperview().inset(16)
        }
        allRoutineRightImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalTo(allRoutineTitleLabel)
            $0.width.equalTo(7)
            $0.height.equalTo(12)
        }
        allRoutineCommentLabel.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(12)
        }

        // 나의 근무지, 매장 섹션
        myWorkplaceSectionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(routineCardStackView.snp.bottom).offset(20)
            $0.leading.equalTo(routineSectionTitleLabel.snp.leading)
        }

        plusButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(6)
            $0.centerY.equalTo(myWorkplaceSectionTitleLabel)
            $0.size.equalTo(44)
        }
    }
}

extension Reactive where Base: HomeHeaderContainerView {
    var todayRoutineCardTap: ControlEvent<Void> {
        return base.todayRoutineCardView.rx.tap
    }

    var allRoutineCardTap: ControlEvent<Void> {
        return base.allRoutineCardView.rx.tap
    }

    var plusButtonTap: ControlEvent<Void> {
        return base.plusButton.rx.tap
    }
}
