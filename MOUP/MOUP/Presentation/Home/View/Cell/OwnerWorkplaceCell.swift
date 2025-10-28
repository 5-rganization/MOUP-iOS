//
//  OwnerWorkplaceCell.swift
//  MOUP
//
//  Created by 송규섭 on 8/1/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

protocol OwnerWorkplaceCellDelegate: AnyObject {
    func didTapAttendanceBtn(workplaceName: String)
}

class OwnerWorkplaceCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "OwnerWorkplaceCell"
    private var workplaceName: String = ""
    weak var delegate: OwnerWorkplaceCellDelegate?
    private let disposeBag = DisposeBag()
    private var isExpanded: Bool = false

    // MARK: - UI Components
    private let containerView = CardButton()
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.spacing = 8
    }

    // 첫 번째 섹션 뷰 - 기초 정보
    private let firstSectionView = UIView()

    private let nameLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }

    fileprivate let menuButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        config.image = .ellipsisButton
        $0.configuration = config
    }

    private let totalEarnedLabel = UILabel().then {
        $0.font = .bodyMedium(14)
        $0.textColor = .gray900
    }

    private let workplaceOfficialChip = WorkplaceOfficialChip()

    // 두 번째 섹션 뷰 - 가변 급여 상세 테이블
    private let secondSectionView = WorkersSalaryView()

    // 세 번째 섹션 뷰 - 출퇴근 버튼
    private let thirdSectionView = UIView()

    private let attendanceButton = UIButton().then {
        $0.setTitle("근태 관리", for: .normal)
        $0.titleLabel?.font = .buttonSemibold(16)
        $0.backgroundColor = .primary50
        $0.setTitleColor(.primary600, for: .normal)
        $0.layer.cornerRadius = 12
    }

    // 네 번째 섹션 뷰
    private let fourthSectionView = UIView()

    private let chevronImageView = UIImageView().then {
        $0.image = .chevronDown
    }

    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configure()
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - prepareForReuse
    override func prepareForReuse() {
        super.prepareForReuse()
        isExpanded = false
        secondSectionView.isHidden = !isExpanded
    }

    // MARK: - Public Methods
    func update(item: HomeSectionItem, menu: UIMenu) {
        switch item {
        case .worker:
            break
        case .owner(let ownerInfo):
            self.nameLabel.text = ownerInfo.workplace.name
            self.workplaceName = ownerInfo.workplace.name
            setTotalEarnedLabel(ownerInfo.workerSummaries)
            self.workplaceOfficialChip.isHidden = !ownerInfo.workplace.isShared
            self.secondSectionView.update(with: ownerInfo.workerSummaries)
            self.menuButton.menu = menu
        }
    }
}

private extension OwnerWorkplaceCell {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setBindings()
    }

    // MARK: - setHierarchy
    func setHierarchy() {
        contentView.addSubviews(containerView)
        containerView.addSubviews(
            stackView,
            menuButton
        )
        firstSectionView.addSubviews(
            nameLabel,
            totalEarnedLabel,
            workplaceOfficialChip
        )
        thirdSectionView.addSubviews(
            attendanceButton
        )
        fourthSectionView.addSubviews(
            chevronImageView
        )
        stackView.addArrangedSubviews(
            firstSectionView,
            secondSectionView,
            thirdSectionView,
            fourthSectionView
        )
    }

    // MARK: - setStyles
    func setStyles() {
        stackView.layer.cornerRadius = 12
        secondSectionView.isHidden = !isExpanded
        menuButton.showsMenuAsPrimaryAction = true
    }

    // MARK: - setConstraints
    func setConstraints() {
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(12).priority(.medium)
        }

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // 첫 번째 섹션
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.equalToSuperview().inset(16)
            $0.height.equalTo(24)
        }

        menuButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().inset(6)
            $0.size.equalTo(44)
        }

        totalEarnedLabel.snp.makeConstraints {
            $0.top.equalTo(menuButton.snp.bottom).offset(10)
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(21)
            $0.bottom.equalToSuperview()
        }

        workplaceOfficialChip.snp.makeConstraints {
            $0.leading.equalTo(nameLabel.snp.trailing).offset(4)
            $0.top.equalToSuperview().inset(15)
        }

        // 두 번째 섹션
        secondSectionView.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalToSuperview()
        }

        // 세 번째 섹션
        attendanceButton.snp.makeConstraints {
            $0.directionalVerticalEdges.equalToSuperview()
            $0.directionalHorizontalEdges.equalToSuperview().inset(18)
            $0.height.equalTo(44)
        }

        // 네 번째 섹션
        chevronImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(8)
            $0.width.equalTo(22)
            $0.height.equalTo(16)
        }
    }
    
    func setBindings() {
        let stackTapGesture = UITapGestureRecognizer()
        stackView.addGestureRecognizer(stackTapGesture)

        stackTapGesture.rx.event
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.isExpanded.toggle()
                owner.toggleSecondSection(owner.isExpanded)
                print("containerView tapped")
            })
            .disposed(by: disposeBag)

        attendanceButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.delegate?.didTapAttendanceBtn(workplaceName: owner.workplaceName)
            })
            .disposed(by: disposeBag)
    }

    func toggleSecondSection(_ expanded: Bool) {
        self.secondSectionView.isHidden = !expanded

        if let tableView = self.superview as? UITableView {
            tableView.beginUpdates()
            self.contentView.layoutIfNeeded()
            tableView.endUpdates()
        }
    }
}

private extension OwnerWorkplaceCell {
    func setTotalEarnedLabel(_ workers: [MonthlyWorkerSummary]) {
        var total = 0
        workers.forEach {
            total += $0.grossIncome // 지불해야 하는 입장이므로 세금 포함
        }
        let fullText = "현재까지 \(total)원"
        let attributed = NSMutableAttributedString(string: fullText, attributes: [
            .font : UIFont.bodyMedium(14),
            .foregroundColor : UIColor.gray900
        ])
        
        if let range = fullText.range(of: "\(total)원") {
            let nsRange = NSRange(range, in: fullText)
            attributed.addAttributes([
                .foregroundColor : UIColor.gray900,
                .font : UIFont.headBold(16)
            ], range: nsRange)
        }
        
        totalEarnedLabel.attributedText = attributed
    }
}
