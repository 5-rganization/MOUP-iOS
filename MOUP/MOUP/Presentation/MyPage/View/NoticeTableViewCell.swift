//
//  NoticeTableViewCell.swift
//  MOUP
//
//  Created by 신영 on 11/1/25.
//

import UIKit
import Then
import SnapKit

final class NoticeTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let id = "NoticeTableViewCell"
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
        $0.numberOfLines = 2
    }
    
    private let dateLabel = UILabel().then {
        $0.font = .fieldsRegular(12)
        $0.textColor = .gray600
    }
    
    private let rightArrow = UIImageView().then {
        $0.image = .myPageChevronRight
        $0.contentMode = .scaleAspectFit
    }
    
    private let separatorView = UIView().then {
        $0.backgroundColor = .gray400
    }
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func update(with notice: Notice, isLast: Bool) {
        titleLabel.text = notice.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        dateLabel.text = dateFormatter.string(from: notice.sentAt)
        
        separatorView.isHidden = isLast
    }
}

private extension NoticeTableViewCell {
    // MARK: - Configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        contentView.addSubviews(
            titleLabel,
            dateLabel,
            rightArrow,
            separatorView
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        selectionStyle = .none
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(titleLabel)
            $0.bottom.equalToSuperview().inset(16)
        }
        
        rightArrow.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16)
        }
        
        separatorView.snp.makeConstraints {
            $0.directionalHorizontalEdges.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
}
