//
//  OLDWorkerCell.swift
//  MOUP
//
//  Created by 양원식 on 12/1/25.
//

import UIKit
import SnapKit
import Then

final class OLDWorkerCell: UITableViewCell {

    var onToggle: (() -> Void)?   // 컨트롤러에게 상태 변경 알림
    
    private let checkButton = UIButton().then {
        $0.setImage(UIImage(named: "CheckboxUnselected"), for: .normal)
        $0.setImage(UIImage(named: "CheckboxSelected"), for: .selected)
    }
    
    private let nameLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .black
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func configure() {
        selectionStyle = .none
        
        contentView.addSubviews(checkButton, nameLabel)
        
        checkButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(checkButton.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        checkButton.addTarget(self, action: #selector(didTapCheck), for: .touchUpInside)
    }
    
    @objc private func didTapCheck() {
        checkButton.isSelected.toggle()
        onToggle?()
    }
    
    func configure(name: String, isSelected: Bool) {
        nameLabel.text = name
        checkButton.isSelected = isSelected
    }
}
