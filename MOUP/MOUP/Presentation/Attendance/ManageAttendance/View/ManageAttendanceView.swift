//
//  ManageAttendanceView.swift
//  MOUP
//
//  Created by 송규섭 on 9/26/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit
import Then

final class ManageAttendanceView: UIView {
    // MARK: - Properties
    
    // MARK: - UI Components
    fileprivate let navigationBar = BaseNavigationBar(title: "근태 관리")
    
    fileprivate let tableView = UITableView().then {
        $0.rowHeight = 48
        $0.isHidden = false
        $0.separatorStyle = .none
        $0.register(ManageAttendanceCell.self, forCellReuseIdentifier: ManageAttendanceCell.identifier)
    }
    
    private let emptyView = ManageAttendanceEmptyView().then {
        $0.isHidden = true
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
    func setupTableView(
        section: Observable<[ManageAttendanceItem]>,
        dataSource: RxTableViewSectionedReloadDataSource<ManageAttendanceItem>
    ) -> Disposable {
        return section.bind(to: tableView.rx.items(dataSource: dataSource))
    }
}

private extension ManageAttendanceView {
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
            emptyView,
            tableView
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
}

extension Reactive where Base: ManageAttendanceView {
    var navBackBtnTapped: ControlEvent<Void> {
        return base.navigationBar.rx.backBtnTapped
    }
    
    var cellSelected: ControlEvent<IndexPath> {
        return base.tableView.rx.itemSelected
    }
    
    var modelSelected: ControlEvent<Employee> {
        return base.tableView.rx.modelSelected(Employee.self)
    }
}
