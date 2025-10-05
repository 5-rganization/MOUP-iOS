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
    private let tableView = UITableView().then {
        $0.rowHeight = 48
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
        
    }
    
    // MARK: - setStyles
    func setStyles() {
        
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        
    }
}


