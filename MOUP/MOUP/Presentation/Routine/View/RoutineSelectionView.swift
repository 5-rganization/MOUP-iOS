//
//  RoutineSelectionView.swift
//  MOUP
//
//  Created by shinyoungkim on 9/14/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class RoutineSelectionView: UIView {

    // MARK: - UI Components
    
    fileprivate let navigationBar = BaseNavigationBar(title: "루틴 선택").then {
        $0.configureRightButton(icon: .plus, title: nil)
    }
    
    private let guideLabel = UILabel().then {
        $0.text = "루틴을 선택해 주세요"
        $0.font = .headBold(18)
        $0.textColor = .gray900
        $0.setLineSpacing(.headBold)
    }
    
    let tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .clear
    }
    
    private let applyButton = BaseButton(title: "적용하기")
    
    weak var dataSource: UITableViewDataSource? {
        get { tableView.dataSource }
        set { tableView.dataSource = newValue }
    }
    
    weak var delegate: UITableViewDelegate? {
        get { tableView.delegate }
        set { tableView.delegate = newValue }
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension RoutineSelectionView {
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
            guideLabel,
            tableView,
            applyButton
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalTo(safeAreaLayoutGuide)
        }
        
        guideLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(32)
            $0.leading.equalTo(safeAreaLayoutGuide).offset(16)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(guideLabel.snp.bottom).offset(24)
            $0.directionalHorizontalEdges.equalTo(safeAreaLayoutGuide)
            $0.bottom.equalTo(applyButton.snp.top).offset(-12)
        }
        
        applyButton.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalTo(safeAreaLayoutGuide).inset(16)
            $0.bottom.equalToSuperview().offset(-36)
            $0.height.equalTo(45)
        }
    }
}

extension Reactive where Base: RoutineSelectionView {
    var plusButtonDidTap: ControlEvent<Void> {
        return base.navigationBar.rx.rightBtnTapped
    }
    
    var itemSelected: ControlEvent<IndexPath> {
        return base.tableView.rx.itemSelected
    }
    
    var deselectRow: Binder<IndexPath> {
        Binder(base) { view, indexPath in
            view.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
