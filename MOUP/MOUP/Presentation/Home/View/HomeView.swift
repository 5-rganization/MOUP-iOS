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
import SnapKit
import Then

final class HomeView: UIView {
    // MARK: - Properties
    private let userRole: UserRole
    private var didConfigureTableHeaderView = false
    
    // MARK: - UI Components
    private let topBar = UIView()
    private let gradient: CAGradientLayer = CAGradientLayer()
    
    private let logoImageView = UIImageView().then {
        $0.image = .homeAppTitle
    }
    
    fileprivate let refreshButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 13.75, leading: 12.98, bottom: 13.75, trailing: 12.98)
        config.image = UIImage.refreshButton
        $0.configuration = config
    }
    
    fileprivate let bellButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = .bellButton
        $0.configuration = config
    }
    
    fileprivate lazy var tableHeaderView = HomeHeaderContainerView(userRole: userRole) // TODO: - 실제 받아온 userRole 반영 필요
    
    fileprivate lazy var tableView = UITableView().then {
        $0.backgroundColor = .white
        $0.estimatedRowHeight = 400
        $0.rowHeight = UITableView.automaticDimension
        $0.register(WorkerWorkplaceCell.self, forCellReuseIdentifier: WorkerWorkplaceCell.identifier)
        $0.register(OwnerWorkplaceCell.self, forCellReuseIdentifier: OwnerWorkplaceCell.identifier)
        $0.separatorStyle = .none
        $0.allowsSelection = false
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
    
    // MARK: - layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // viewDidLoad, init에서 호출 시 제약조건 충돌 발생으로 인해 플래그 사용
        if !didConfigureTableHeaderView && bounds.width > 0 {
            setTableHeaderView()
            didConfigureTableHeaderView = true
        }
    }
    
    // MARK: - Public Methods
    func setupTableView(
        section: Observable<[HomeTableViewFirstSection]>,
        dataSource: RxTableViewSectionedAnimatedDataSource<HomeTableViewFirstSection>
    ) -> Disposable {
        return section
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(dataSource: dataSource))
    }
    
    func updateHomeHeader(headerData: HomeHeaderData) {
        tableHeaderView.update(data: headerData)
    }
    
    func updateActiveWorkplace(_ active: WorkplaceMonthSummary?) {
        for case let cell as WorkerWorkplaceCell in tableView.visibleCells {
            cell.updateAttendanceState(activatedId: active?.homeWorkplace.workplace.id)
        }
    }
    
    func updateBellButton(hasUnread: Bool) {
        let imageName: UIImage? = hasUnread ? .bellButtonWithDot : .bellButton
        var config = bellButton.configuration
        config?.image = imageName
        bellButton.configuration = config
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
        topBar.addSubviews(logoImageView, refreshButton, bellButton)
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .primaryBackground
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
            $0.trailing.equalTo(bellButton.snp.leading)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(44)
        }
        
        bellButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(8)
            $0.centerY.equalTo(refreshButton.snp.centerY)
            $0.size.equalTo(44)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(topBar.snp.bottom)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
    
    func setTableHeaderView() {
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
    
    var refreshBtnTap: ControlEvent<Void> {
        return base.refreshButton.rx.tap
    }
    
    var bellButtonTap: ControlEvent<Void> {
        return base.bellButton.rx.tap
    }
}
