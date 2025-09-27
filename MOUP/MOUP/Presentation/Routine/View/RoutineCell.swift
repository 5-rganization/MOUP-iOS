//
//  RoutineCell.swift
//  MOUP
//
//  Created by shinyoungkim on 9/14/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

final class RoutineCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let id = "RoutineCell"
    
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    fileprivate let checkboxButton = UIButton().then {
        $0.setImage(UIImage.checkboxUnselected, for: .normal)
        $0.setImage(UIImage.checkboxSelected, for: .selected)
        $0.contentMode = .scaleAspectFit
    }
    
    private let nameLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
        $0.setLineSpacing(.bodyMedium)
    }
    
    private let timeLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
        $0.setLineSpacing(.bodyMedium)
    }
    
    private let rightArrow = UIImageView().then {
        $0.image = UIImage.myPageChevronRight
        $0.contentMode = .scaleAspectFit
    }
    
    private let separator = UIView().then {
        $0.backgroundColor = .gray300
    }
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
        checkboxButton.isSelected = false
        nameLabel.text = nil
        timeLabel.text = nil
    }
    
    // MARK: - Public Methods
    
    func update(with viewState: RoutineRowViewState) {
        nameLabel.text = viewState.routine.title
        
        if let time = viewState.routine.alarmTime,
           let hour = time.hour,
           let minute = time.minute {
            timeLabel.text = String(format: "%02d : %02d", hour, minute)
        } else {
            timeLabel.text = "알림 없음"
        }
        
        checkboxButton.isSelected = viewState.isChecked
    }
}

private extension RoutineCell {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        contentView.addSubviews(
            checkboxButton,
            nameLabel,
            timeLabel,
            rightArrow,
            separator
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        selectionStyle = .none
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        checkboxButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(24)
        }
        
        nameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(checkboxButton.snp.trailing).offset(12)
        }
        
        timeLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(nameLabel.snp.trailing).offset(12)
        }
        
        rightArrow.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16)
        }
        
        separator.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
    }
}

extension Reactive where Base: RoutineCell {
    var checkboxDidTap: ControlEvent<Void> {
        return base.checkboxButton.rx.tap
    }
}
