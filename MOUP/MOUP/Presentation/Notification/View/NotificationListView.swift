//
//  NotificationListView.swift
//  MOUP
//
//  Created by 신영 on 11/2/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

final class NotificationListView: UIView {
    
    // MARK: - Properties
    
    fileprivate let notificationTappedSubject = PublishSubject<UserNotification>()
    fileprivate let markAllAsReadSubject = PublishSubject<Void>()
    fileprivate let deleteAllSubject = PublishSubject<Void>()
    fileprivate let deleteSubject = PublishSubject<UserNotification>()
    private var notifications: [UserNotification] = []
    
    // MARK: - UI Components
    
    fileprivate let navigationBar = BaseNavigationBar(title: "알림")
        
    private let actionButtonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.distribution = .fillEqually
    }
    
    fileprivate let deleteAllButton = UIButton().then {
        $0.setTitle("모두 삭제", for: .normal)
        $0.setTitleColor(.gray600, for: .normal)
        $0.titleLabel?.font = .buttonSemibold(16)
        $0.backgroundColor = .gray200
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    fileprivate let markAllReadButton = UIButton().then {
        $0.setTitle("모두 읽음", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .buttonSemibold(16)
        $0.backgroundColor = .primary500
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    fileprivate let tableView = UITableView().then {
        $0.register(
            NotificationTableViewCell.self,
            forCellReuseIdentifier: NotificationTableViewCell.identifier
        )
        $0.separatorStyle = .none
        $0.backgroundColor = .white
    }
    
    private let emptyLabel = UILabel().then {
        $0.text = "알림이 없습니다"
        $0.font = .bodyMedium(16)
        $0.textColor = .gray600
        $0.isHidden = true
    }
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large).then {
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
    
    func updateNotifications(_ notifications: [UserNotification]) {
        self.notifications = notifications
        emptyLabel.isHidden = !notifications.isEmpty
        actionButtonStackView.isHidden = notifications.isEmpty
        tableView.reloadData()
    }
}

private extension NotificationListView {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setTableView()
    }
    
    func setHierarchy() {
        addSubviews(
            navigationBar,
            actionButtonStackView,
            tableView,
            emptyLabel,
            loadingIndicator
        )
        
        actionButtonStackView.addArrangedSubviews(
            deleteAllButton,
            markAllReadButton
        )
    }
    
    func setStyles() {
        backgroundColor = .white
    }
    
    func setConstraints() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalTo(safeAreaLayoutGuide)
        }
        
        actionButtonStackView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(20)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(actionButtonStackView.snp.bottom).offset(12)
            $0.directionalHorizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
        }
        
        emptyLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func setTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension NotificationListView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NotificationTableViewCell.identifier,
            for: indexPath
        ) as? NotificationTableViewCell else {
            return UITableViewCell()
        }
        
        let notification = notifications[indexPath.row]
        cell.configure(with: notification)
        
        return cell
    }
}

extension NotificationListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        notificationTappedSubject.onNext(notification)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }
            let notification = self.notifications[indexPath.row]
            
            self.deleteSubject.onNext(notification)
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension Reactive where Base: NotificationListView {
    var backButtonTapped: ControlEvent<Void> {
        base.navigationBar.rx.backBtnTapped
    }
    
    var notificationTapped: ControlEvent<UserNotification> {
        ControlEvent(events: base.notificationTappedSubject)
    }
    
    var markAllReadTapped: ControlEvent<Void> {
        base.markAllReadButton.rx.tap
    }
    
    var deleteAllTapped: ControlEvent<Void> {
        base.deleteAllButton.rx.tap
    }
    
    var deleteTapped: ControlEvent<UserNotification> {
        ControlEvent(events: base.deleteSubject)
    }
}
