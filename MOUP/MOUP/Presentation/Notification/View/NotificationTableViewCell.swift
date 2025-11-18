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
    
    // MARK: - Properties
    
    static let identifier = "NotificationTableViewCell"
    var onApprove: (() -> Void)?
    var onReject:(() -> Void)?
    
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
    }
    
    // MARK: - Public Methods
    
    func configure(with notification: UserNotification) {
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
        
        if notification.type == .inviteRequest {
              actionButtonStackView.isHidden = false

              contentLabel.snp.remakeConstraints {
                  $0.top.equalTo(titleLabel.snp.bottom).offset(4)
                  $0.leading.equalTo(titleLabel)
                  $0.trailing.equalToSuperview().inset(16)
              }

              actionButtonStackView.snp.remakeConstraints {
                  $0.top.equalTo(contentLabel.snp.bottom).offset(12)
                  $0.leading.equalTo(titleLabel)
                  $0.trailing.equalToSuperview().inset(16)
                  $0.height.equalTo(36)
                  $0.bottom.equalToSuperview().inset(12)
              }
          } else {
              actionButtonStackView.isHidden = true

              contentLabel.snp.remakeConstraints {
                  $0.top.equalTo(titleLabel.snp.bottom).offset(4)
                  $0.leading.equalTo(titleLabel)
                  $0.trailing.equalToSuperview().inset(16)
                  $0.bottom.equalToSuperview().inset(12)
              }
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
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
    }
    
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
    
    func setStyles() {
        selectionStyle = .none
        backgroundColor = .white
    }
    
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
            $0.bottom.equalToSuperview().inset(12)
        }
    }
    
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
        onApprove?()
    }

    @objc func handleReject() {
        onReject?()
    }
}
