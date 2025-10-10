//
//  ManageAttendanceCell.swift
//  MOUP
//
//  Created by 송규섭 on 9/26/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class ManageAttendanceCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "ManageAttendanceCell"

    // MARK: - UI Components
    private let colorDot = UIView().then {
        $0.layer.cornerRadius = 6
    }
    
    private let nameLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = .bodyMedium(16)
    }

    private let bottomLine = UIView().then {
        $0.backgroundColor = .gray300
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
    
    // MARK: - Public Methods
    func update(color: UIColor, name: String) {
        colorDot.backgroundColor = color
        nameLabel.text = name
    }
}

private extension ManageAttendanceCell {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    func setHierarchy() {
        contentView.addSubviews(
            colorDot,
            nameLabel,
            bottomLine
        )
    }
    
    func setStyles() {
        contentView.backgroundColor = .primaryBackground
    }
    
    func setConstraints() {
        colorDot.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
            $0.size.equalTo(12)
        }
        
        nameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(colorDot.snp.trailing).offset(12)
        }
        
        bottomLine.snp.makeConstraints {
            $0.directionalHorizontalEdges.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
}
