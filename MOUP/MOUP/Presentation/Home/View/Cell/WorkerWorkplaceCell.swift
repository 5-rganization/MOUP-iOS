//
//  WorkerWorkplaceCell.swift
//  MOUP
//
//  Created by 송규섭 on 8/1/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

class WorkerWorkplaceCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "WorkerWorkplaceCell"
    private let disposeBag = DisposeBag()
    private var isExpanded: Bool = false
    private var dummyHeightConstraint: Constraint?

    // MARK: - UI Components
    private let containerView = CardButton()
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.spacing = 8
        $0.isUserInteractionEnabled = false
    }

    // 첫 번째 섹션 뷰 - 기초 정보
    private let firstSectionView = UIView()

    private let nameLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }

    private let untilPaydayLabel = UILabel().then {
        $0.font = .bodyMedium(12)
        $0.textColor = .gray700
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

    // 두 번째 섹션 뷰 - 가변 급여 상세 테이블
    private let secondSectionView = UIView()
    private let dummyView = UIView().then {
        $0.backgroundColor = .yellow
    }

    // 세 번째 섹션 뷰 - 출퇴근 버튼
    private let thirdSectionView = UIView()
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
        dummyHeightConstraint?.update(offset: 0)
    }

    // MARK: - Public Methods
    func update(item: HomeSectionItem) {
        switch item {
        case .worker(let workerInfo):
            self.nameLabel.text = workerInfo.workplace.name
            self.untilPaydayLabel.text = "sdfdfs"
            self.totalEarnedLabel.text = "dsfdsf"
        case .owner:
            break
        }
    }
}

private extension WorkerWorkplaceCell {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setConstraints()
        setStyles()
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
            untilPaydayLabel,
            totalEarnedLabel
        )
        secondSectionView.addSubviews(
            dummyView
        )
        thirdSectionView.addSubviews(
            chevronImageView
        )
        stackView.addArrangedSubviews(
            firstSectionView,
            secondSectionView,
            thirdSectionView
        )
    }

    // MARK: - setStyles
    func setStyles() {
        stackView.layer.cornerRadius = 12
    }

    // MARK: - setConstraints
    func setConstraints() {
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(12)
        }

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // 첫 번째 섹션
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.equalToSuperview().inset(16)
        }

        untilPaydayLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom)
            $0.leading.equalToSuperview().inset(16)
        }

        menuButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().inset(6)
            $0.size.equalTo(44)
        }

        totalEarnedLabel.snp.makeConstraints {
            $0.top.equalTo(menuButton.snp.bottom).offset(10)
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
        }

        // 두 번째 섹션
        dummyView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            dummyHeightConstraint = $0.height.equalTo(0).priority(.medium).constraint
        }

        // 세 번째 섹션
        chevronImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(8)
            $0.width.equalTo(22)
            $0.height.equalTo(16)
        }
    }

    func setBindings() {
        containerView.rx.tap.subscribe(onNext: { [weak self] in
            guard let self else { return }
            isExpanded.toggle()
            toggleSecondSection(isExpanded)
            print("containerView tapped")
        })
        .disposed(by: disposeBag)

        menuButton.rx.tap.subscribe(onNext: {
            print("메뉴버튼탭")
        })
        .disposed(by: disposeBag)
    }

    func toggleSecondSection(_ expanded: Bool) {
        self.dummyHeightConstraint?.update(offset: expanded ? 200 : 0)
        if let tableView = self.superview as? UITableView {
            tableView.beginUpdates()
            self.contentView.layoutIfNeeded()
            tableView.endUpdates()
        }
    }
}


