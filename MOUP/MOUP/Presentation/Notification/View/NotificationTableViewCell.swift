//
//  NotificationTableViewCell.swift
//  MOUP
//
//  Created by 신영 on 11/2/25.
//

import UIKit
import Then
import SnapKit

final class NotificationTableViewCell: UITableViewCell {
    
    // MARK: - Button State

    private enum ButtonState {
        case initial
        case approved
        case rejected
    }

    // MARK: - Properties
    
    static let identifier = "NotificationTableViewCell"
    var onApprove: ((Int) -> Void)?
    var onReject: ((Int) -> Void)?
    private var currentState: ButtonState = .initial
    private var currentNotificationId: Int?
    
    // MARK: - UI Components
    
    private let statusIcon = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .readNotification
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
        $0.numberOfLines = 1
    }
    
    private let contentLabel = UILabel().then {
        $0.font = .bodyMedium(14)
        $0.textColor = .gray700
        $0.numberOfLines = 2
    }
    
    private let timeLabel = UILabel().then {
        $0.font = .bodyMedium(12)
        $0.textColor = .gray400
    }
    
    private lazy var actionButtonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.distribution = .fillEqually
        $0.isHidden = true
    }

    private lazy var rejectButton = UIButton().then {
        $0.setTitle("거절", for: .normal)
        $0.setTitleColor(.gray700, for: .normal)
        $0.titleLabel?.font = .buttonSemibold(14)
        $0.backgroundColor = .gray200
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }

    private lazy var approveButton = UIButton().then {
        $0.setTitle("승인", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .buttonSemibold(14)
        $0.backgroundColor = .primary500
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        backgroundColor = .white
        statusIcon.image = .readNotification
        titleLabel.text = nil
        contentLabel.text = nil
        timeLabel.text = nil
        
        actionButtonStackView.isHidden = true
        onApprove = nil
        onReject = nil
        approveButton.isHidden = false
        rejectButton.isHidden = false
        approveButton.alpha = 1.0
        rejectButton.alpha = 1.0
        approveButton.isEnabled = true
        rejectButton.isEnabled = true
        actionButtonStackView.distribution = .fillEqually

        contentLabel.snp.removeConstraints()
        actionButtonStackView.snp.removeConstraints()
    }
    
    // MARK: - Public Methods
    
    func configure(with notification: UserNotification) {
        if currentNotificationId != notification.id {
            currentState = .initial
            currentNotificationId = notification.id
        }

        titleLabel.text = notification.title
        contentLabel.text = notification.content
        
        if notification.isRead {
            statusIcon.image = .readNotification
            backgroundColor = .white
        } else {
            statusIcon.image = .unReadNotification
            backgroundColor = .primary50
        }
        
        timeLabel.text = formatTimeAgo(notification.sentAt)
        
        let shouldShowButtons = notification.type == .inviteRequest ||
                                notification.type == .inviteApproved ||
                                notification.type == .inviteRejected

        if shouldShowButtons {
            actionButtonStackView.isHidden = false

            contentLabel.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(4)
                $0.leading.equalTo(titleLabel)
                $0.trailing.equalToSuperview().inset(16)
            }

            actionButtonStackView.snp.makeConstraints {
                $0.top.equalTo(contentLabel.snp.bottom).offset(12)
                $0.leading.equalTo(titleLabel)
                $0.trailing.equalToSuperview().inset(16)
                $0.height.equalTo(36)
                $0.bottom.equalToSuperview().inset(12)
            }
            
            configureButtonState(for: notification.type)
        } else {
            actionButtonStackView.isHidden = true

            contentLabel.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(4)
                $0.leading.equalTo(titleLabel)
                $0.trailing.equalToSuperview().inset(16)
                $0.bottom.equalToSuperview().inset(12)
            }
        }
    }
    
    private func configureButtonState(for type: PushNotificationType?) {
        switch type {
        case .inviteRequest:
            currentState = .initial
        case .inviteApproved:
            currentState = .approved
        case .inviteRejected:
            currentState = .rejected
        default:
            break
        }
        
        applyButtonState()
    }
    
    private func applyButtonState() {
        switch currentState {
        case .initial:
            approveButton.isHidden = false
            rejectButton.isHidden = false
            approveButton.alpha = 1.0
            rejectButton.alpha = 1.0
            approveButton.isEnabled = true
            rejectButton.isEnabled = true
            actionButtonStackView.distribution = .fillEqually
        case .approved:
            approveButton.isHidden = false
            rejectButton.isHidden = true
            approveButton.alpha = 1.0
            rejectButton.alpha = 0
            approveButton.isEnabled = false
            rejectButton.isEnabled = false
            actionButtonStackView.distribution = .fill
        case .rejected:
            approveButton.isHidden = true
            rejectButton.isHidden = false
            approveButton.alpha = 0
            rejectButton.alpha = 1.0
            approveButton.isEnabled = false
            rejectButton.isEnabled = false
            actionButtonStackView.distribution = .fill
        }
    }

    private func formatTimeAgo(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let day = components.day, day > 0 {
            if day == 1 {
                return "어제"
            } else if day < 7 {
                return "\(day)일 전"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM.dd"
                return formatter.string(from: date)
            }
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)시간 전"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)분 전"
        } else {
            return "방금"
        }
    }
}

private extension NotificationTableViewCell {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        contentView.addSubviews(
            statusIcon,
            titleLabel,
            contentLabel,
            timeLabel,
            actionButtonStackView
        )
        
        actionButtonStackView.addArrangedSubviews(
            rejectButton,
            approveButton
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        selectionStyle = .none
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        statusIcon.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(32)
        }
        
        timeLabel.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalTo(statusIcon.snp.trailing).offset(16)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(16)
        }
    }
    
    // MARK: - setActions
    func setActions() {
        approveButton.addTarget(
            self,
            action: #selector(handleApprove),
            for: .touchUpInside
        )
        rejectButton.addTarget(
            self,
            action: #selector(handleReject),
            for: .touchUpInside
        )
    }

    @objc func handleApprove() {
        guard currentState == .initial,
              let notificationId = currentNotificationId else { return }
        currentState = .approved
        animateToApproved()
        onApprove?(notificationId)
    }

    @objc func handleReject() {
        guard currentState == .initial,
              let notificationId = currentNotificationId else { return }
        currentState = .rejected
        animateToRejected()
        onReject?(notificationId)
    }

    // MARK: - Animation Methods

    func animateToApproved() {
        approveButton.isEnabled = false
        rejectButton.isEnabled = false

        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseInOut
        ) {
            self.rejectButton.alpha = 0
            self.layoutIfNeeded()
        } completion: { _ in
            self.rejectButton.isHidden = true
            self.actionButtonStackView.distribution = .fill
        }
    }

    func animateToRejected() {
        approveButton.isEnabled = false
        rejectButton.isEnabled = false

        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseInOut
        ) {
            self.approveButton.alpha = 0
            self.layoutIfNeeded()
        } completion: { _ in
            self.approveButton.isHidden = true
            self.actionButtonStackView.distribution = .fill
        }
    }
}
