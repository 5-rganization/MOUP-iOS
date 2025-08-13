//
//  HomeView.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class HomeView: UIView {
    // MARK: - Properties

    // MARK: - UI Components
    private let topBar = UIView()
    private let gradient: CAGradientLayer = CAGradientLayer()

    private let logoImageView = UIImageView().then {
        $0.image = .homeAppTitle
    }

    private let refreshButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 13.75, leading: 12.98, bottom: 13.75, trailing: 12.98)
        config.image = UIImage.refreshButton
        $0.configuration = config
    }

    fileprivate let tableHeaderView = HomeHeaderContainerView(userRole: .worker) // TODO: - 실제 받아온 userRole 반영 필요
    fileprivate lazy var tableView = UITableView().then {
        $0.backgroundColor = .white
        $0.estimatedRowHeight = 300
        $0.rowHeight = UITableView.automaticDimension
        $0.register(WorkerWorkplaceCell.self, forCellReuseIdentifier: WorkerWorkplaceCell.identifier)
        $0.register(OwnerWorkplaceCell.self, forCellReuseIdentifier: OwnerWorkplaceCell.identifier)
    }

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("HomeView init - frame: \(frame)")
        configure()
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()

        setTableHeaderView()
    }

    // MARK: - Public Methods
    func setupTableView(
        section: Observable<[HomeTableViewFirstSection]>,
        dataSource: RxTableViewSectionedAnimatedDataSource<HomeTableViewFirstSection>
    ) -> Disposable {
        return section.bind(to: tableView.rx.items(dataSource: dataSource))
    }
}

private extension HomeView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }

    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(topBar, tableView)
        topBar.addSubviews(logoImageView, refreshButton)
    }

    // MARK: - setStyles
    func setStyles() {
        
    }

    // MARK: - setConstraints
    func setConstraints() {
        topBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.height.equalTo(50)
        }

        logoImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(75)
            $0.height.equalTo(32)
        }

        refreshButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(44)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(topBar.snp.bottom)
            $0.directionalHorizontalEdges.bottom.equalToSuperview()
        }
    }

    func setTableHeaderView() {
        // TODO: - 테이블뷰 셀 상단 영역 8을 그림자를 위해 남겨놨으니 설정 필요
        tableHeaderView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 332)
        tableView.tableHeaderView = tableHeaderView
    }

}

extension Reactive where Base: HomeView {
    var todayRoutineCardTap: ControlEvent<Void> {
        return base.tableHeaderView.rx.todayRoutineCardTap
    }

    var allRoutineCardTap: ControlEvent<Void> {
        return base.tableHeaderView.rx.allRoutineCardTap
    }

    var plusButtonTap: ControlEvent<Void> {
        return base.tableHeaderView.rx.plusButtonTap
    }
}
