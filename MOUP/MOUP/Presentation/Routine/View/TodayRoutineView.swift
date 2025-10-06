//
//  TodayRoutineView.swift
//  MOUP
//
//  Created by 송규섭 on 10/5/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit
import Then

final class TodayRoutineView: UIView {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    fileprivate let navigationBar = BaseNavigationBar(title: "오늘의 루틴")
    
    fileprivate let tableView = UITableView().then {
        $0.rowHeight = 60
        $0.register(TodayRoutineCell.self, forCellReuseIdentifier: TodayRoutineCell.identifier)
        $0.contentInset = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
        $0.separatorStyle = .none
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
        section: Observable<[TodayRoutineItem]>,
        dataSource: RxTableViewSectionedReloadDataSource<TodayRoutineItem>
    ) -> Disposable {
        return section.bind(to: tableView.rx.items(dataSource: dataSource))
    }
}

private extension TodayRoutineView {
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

extension Reactive where Base: TodayRoutineView {
    var itemSelected: ControlEvent<IndexPath> {
        return base.tableView.rx.itemSelected
    }
    
    var modelSelected: ControlEvent<TodayRoutine> {
        return base.tableView.rx.modelSelected(TodayRoutine.self)
    }
    
    var navBackBtnTapped: ControlEvent<Void> {
        return base.navigationBar.rx.backBtnTapped
    }
    
    var navRightBtnTapped: ControlEvent<Void> {
        return base.navigationBar.rx.rightBtnTapped
    }
}
