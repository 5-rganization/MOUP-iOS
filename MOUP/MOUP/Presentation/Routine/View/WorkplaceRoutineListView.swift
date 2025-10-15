//
//  WorkplaceRoutineListView.swift
//  MOUP
//
//  Created by 송규섭 on 10/6/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit
import Then

final class WorkplaceRoutineListView: UIView {
    // MARK: - Properties
    private let workplaceName: String
    
    // MARK: - UI Components
    fileprivate lazy var navigationBar = BaseNavigationBar(title: workplaceName)
    
    fileprivate let tableView = UITableView().then {
        $0.rowHeight = 60
        $0.contentInset = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
        $0.separatorStyle = .none
        $0.register(RoutineListCell.self, forCellReuseIdentifier: RoutineListCell.identifier)
    }
    
    // MARK: - Initializer
    init(workplaceName: String) {
        self.workplaceName = workplaceName
        super.init(frame: .zero)
        
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Public Methods
    func setupTableView(
        section: Observable<[RoutineItem]>,
        dataSource: RxTableViewSectionedReloadDataSource<RoutineItem>
    ) -> Disposable {
        return section.bind(to: tableView.rx.items(dataSource: dataSource))
    }
}

private extension WorkplaceRoutineListView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            navigationBar,
            tableView
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .primaryBackground
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
}

extension Reactive where Base: WorkplaceRoutineListView {
    var itemSelected: ControlEvent<IndexPath> {
        base.tableView.rx.itemSelected
    }
    
    var modelSelected: ControlEvent<Routine> {
        base.tableView.rx.modelSelected(Routine.self)
    }
    
    var navBackBtnTapped: ControlEvent<Void> {
        return base.navigationBar.rx.backBtnTapped
    }
}
