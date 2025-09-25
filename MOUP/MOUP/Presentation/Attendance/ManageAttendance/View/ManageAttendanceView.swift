//
//  ManageAttendanceView.swift
//  MOUP
//
//  Created by 송규섭 on 9/26/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class ManageAttendanceView: UIView {
    // MARK: - Properties
    
    // MARK: - UI Components
    fileprivate let navigationBar = BaseNavigationBar(title: "근태 관리")
    
    private let tableView = UITableView().then {
        $0.rowHeight = 48
        $0.isHidden = true
    }
    
    private let emptyView = ManageAttendanceEmptyView().then {
        $0.isHidden = false
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
            emptyView
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
    }
}

extension Reactive where Base: ManageAttendanceView {
    var navBackBtnTapped: ControlEvent<Void> {
        return base.navigationBar.rx.backBtnTapped
    }
}
