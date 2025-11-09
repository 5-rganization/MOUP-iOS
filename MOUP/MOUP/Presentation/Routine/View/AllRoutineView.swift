//
//  AllRoutineView.swift
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

final class AllRoutineView: UIView {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    fileprivate let navigationBar = BaseNavigationBar(title: "전체 루틴").then {
        $0.configureRightButton(icon: .plus, title: nil)
    }
    
    fileprivate let tableView = UITableView().then {
        $0.rowHeight = 60 // 상하 각 6, 컨텐츠 48
        $0.register(RoutineListCell.self, forCellReuseIdentifier: RoutineListCell.identifier)
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
        section: Observable<[RoutineItem]>,
        dataSource: RxTableViewSectionedReloadDataSource<RoutineItem>
    ) -> Disposable {
        return section.bind(to: tableView.rx.items(dataSource: dataSource))
    }
}

private extension AllRoutineView {
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

extension Reactive where Base: AllRoutineView {
    var itemSelected: ControlEvent<IndexPath> {
        return base.tableView.rx.itemSelected
    }
    
    var modelSeleted: ControlEvent<RoutineSummary> {
        return base.tableView.rx.modelSelected(RoutineSummary.self)
    }
    
    var navBackBtnTapped: ControlEvent<Void> {
        return base.navigationBar.rx.backBtnTapped
    }
    
    var navRightBtnTapped: ControlEvent<Void> {
        return base.navigationBar.rx.rightBtnTapped
    }
}
