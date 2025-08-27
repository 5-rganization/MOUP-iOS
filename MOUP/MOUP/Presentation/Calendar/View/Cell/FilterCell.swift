//
//  FilterCell.swift
//  MOUP
//
//  Created by 서동환 on 7/31/25.
//

import UIKit

import SnapKit
import Then

/// 필터 목록 셀
final class FilterCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = String(describing: FilterCell.self)
    
    // MARK: - UI Components
    private let workplaceNameLabel = UILabel().then {
        $0.text = "전체 보기"
        $0.textColor = .gray500
        $0.font = .headBold(14)
    }
    
    private let checkImageView = UIImageView().then {
        $0.image = .check
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = self.contentView.frame.inset(by: UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        self.contentView.backgroundColor = selected ? .primary50 : .primaryBackground
        self.contentView.layer.borderWidth = selected ? 2.0 : 1.0
        self.contentView.layer.borderColor = selected ? UIColor.primary500.cgColor : UIColor.gray400.cgColor
        
        workplaceNameLabel.font = selected ? .headBold(14) : .bodyMedium(14)
        workplaceNameLabel.textColor = selected ? .primary600 : .gray500
        checkImageView.isHidden = !selected
    }
    
    // MARK: - Internal Methods
    func update(workplaceName: String) {
        workplaceNameLabel.text = workplaceName
    }
}

private extension FilterCell {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        self.contentView.addSubviews(workplaceNameLabel,
                                     checkImageView)
    }
    
    // MARK: - setStyles
    func setStyles() {
        self.contentView.backgroundColor = .gray100
        
        self.contentView.layer.cornerRadius = 8
        self.contentView.layer.borderColor = UIColor.gray400.cgColor
        self.contentView.layer.borderWidth = 1.0
        
        self.selectionStyle = .none
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        workplaceNameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        checkImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(16)
        }
    }
}
