//
//  OLDSelectedWorkerView.swift
//  MOUP
//
//  Created by 양원식 on 12/1/25.
//

import UIKit
import SnapKit
import Then
import RxRelay
import RxSwift
import RxCocoa

final class OLDSelectedWorkerView: UIView {

    // MARK: - UI Components
    fileprivate let navigationBar = BaseNavigationBar(title: "인원 선택")
    
    private let titleLabel = UILabel().then {
        $0.text = "근무할 알바생을 선택해 주세요"
        $0.textColor = .black
        $0.font = .headBold(16)
        $0.textAlignment = .left
        $0.numberOfLines = 1
    }
    
    // 알바 목록 (동적 리스트)
    fileprivate let tableView = UITableView().then {
        $0.separatorInset = .zero
        $0.rowHeight = 56
        $0.allowsMultipleSelection = true
        $0.showsVerticalScrollIndicator = false
        $0.register(OLDWorkerCell.self, forCellReuseIdentifier: "WorkerCell")
    }
    
    private let registerButton = BaseButton(title: "적용하기").then {
        $0.isEnabled = false
    }
    var getRegisterButton: BaseButton { registerButton }
    var getTableView: UITableView { tableView }
    var getNavigationBar: BaseNavigationBar { navigationBar }
    
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
}

private extension OLDSelectedWorkerView {
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
            titleLabel,
            tableView,
            registerButton
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
            $0.directionalHorizontalEdges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(registerButton.snp.top).offset(-12)
        }
        
        registerButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(45)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(12)
        }
    }
}
