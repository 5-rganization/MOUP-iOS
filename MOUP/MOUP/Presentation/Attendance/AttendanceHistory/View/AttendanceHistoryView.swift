//
//  ManageAttendanceView.swift
//  MOUP
//
//  Created by 송규섭 on 9/24/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit
import Then

final class AttendanceHistoryView: UIView {
    // MARK: - Properties
    private let title: String
    
    // MARK: - UI Components
    fileprivate lazy var navigationBar = BaseNavigationBar(title: title)
    
    private let leftVerticalDivider = UIView().then {
        $0.backgroundColor = .gray400
    }
    
    private let rightVerticalDivider = UIView().then {
        $0.backgroundColor = .gray400
    }
    
    fileprivate let tableView = UITableView().then {
        $0.rowHeight = 60
        $0.separatorStyle = .none
        $0.allowsSelection = false
        $0.bounces = false
        $0.sectionHeaderTopPadding = 0
        $0.register(AttendanceHistoryTableHeaderView.self, forHeaderFooterViewReuseIdentifier: AttendanceHistoryTableHeaderView.identifier)
        $0.register(AttendanceCell.self, forCellReuseIdentifier: AttendanceCell.identifier)
    }
    
    // MARK: - Initializer
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Public Methods
    func setupTableView(
        section: Observable<[AttendanceItem]>,
        dataSource: RxTableViewSectionedReloadDataSource<AttendanceItem>
    ) -> Disposable {
        return section.bind(to: tableView.rx.items(dataSource: dataSource))
    }
}

private extension AttendanceHistoryView {
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
            tableView,
            leftVerticalDivider,
            rightVerticalDivider
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
        
        leftVerticalDivider.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.leading.equalToSuperview().inset(125)
            $0.bottom.equalToSuperview()
            $0.width.equalTo(1)
        }
        
        rightVerticalDivider.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.width.equalTo(1)
            $0.leading.equalTo(leftVerticalDivider.snp.trailing)
                    .offset((UIScreen.main.bounds.width - 125 - 1) / 2)
            $0.bottom.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}

extension Reactive where Base: AttendanceHistoryView {
    func setDelegate(_ delegate: UITableViewDelegate) -> Disposable {
        return base.tableView.rx.setDelegate(delegate)
    }
    
    var navBackBtnTapped: ControlEvent<Void> {
        return base.navigationBar.rx.backBtnTapped
    }
}
