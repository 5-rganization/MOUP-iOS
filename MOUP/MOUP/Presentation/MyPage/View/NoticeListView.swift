//
//  NoticeListView.swift
//  MOUP
//
//  Created by 신영 on 11/1/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

final class NoticeListView: UIView {
    
    // MARK: - Properties
    
    fileprivate let noticeTappedSubject = PublishSubject<Notice>()
    private var notices: [Notice] = []
    
    // MARK: - UI Components
    
    fileprivate let navigationBar = BaseNavigationBar(title: "공지사항")
    
    fileprivate let tableView = UITableView().then {
        $0.register(
            NoticeTableViewCell.self,
            forCellReuseIdentifier: NoticeTableViewCell.id
        )
        $0.separatorStyle = .none
        $0.backgroundColor = .white
    }
    
    private let emptyLabel = UILabel().then {
        $0.text = "공지사항이 없습니다"
        $0.font = .bodyMedium(16)
        $0.textColor = .gray600
        $0.isHidden = true
    }
    
    private let loadingIndicator = UIActivityIndicatorView(
        style: .large
    ).then {
        $0.color = .primary500
        $0.hidesWhenStopped = true
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
    
    // MARK: - Public Methods
    
    func showLoading() {
        loadingIndicator.startAnimating()
        tableView.alpha = 0
        emptyLabel.isHidden = true
    }
    
    func hideLoading() {
        loadingIndicator.stopAnimating()
        
        UIView.animate(withDuration: 0.3) {
            self.tableView.alpha = 1
        }
    }
    
    func updateNotices(_ notices: [Notice]) {
        self.notices = notices
        emptyLabel.isHidden = !notices.isEmpty
        tableView.reloadData()
    }
}

private extension NoticeListView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setTableView()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            navigationBar,
            tableView,
            emptyLabel,
            loadingIndicator
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
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(12)
            $0.directionalHorizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
        }
        
        emptyLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    // MARK: - setTableView
    func setTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension NoticeListView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NoticeTableViewCell.id,
            for: indexPath
        ) as? NoticeTableViewCell else {
            return UITableViewCell()
        }
        
        let notice = notices[indexPath.row]
        let isLast = indexPath.row == notices.count - 1
        cell.update(with: notice, isLast: isLast)
        
        return cell
    }
}

extension NoticeListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notice = notices[indexPath.row]
        noticeTappedSubject.onNext(notice)
    }
}

extension Reactive where Base: NoticeListView {
    var backButtonTapped: ControlEvent<Void> {
        base.navigationBar.rx.backBtnTapped
    }
    
    var noticeTapped: ControlEvent<Notice> {
        ControlEvent(events: base.noticeTappedSubject)
    }
}
