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
    fileprivate let checkboxTapSubject = PublishSubject<Void>()
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    fileprivate let checkBox = UIImageView().then {
        $0.image = UIImage.checkboxUnselected
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = true
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
        setActions()
    }
    
    // MARK: - Public Methods
    
    func update(name: String, time: String) {
        nameLabel.text = name
        timeLabel.text = time
    }
    
    func set(name: String, time: String, isChecked: Bool) {
        update(name: name, time: time)
        setChecked(isChecked)
    }
    
    func setChecked(_ checked: Bool) {
        checkBox.image = checked ? UIImage.checkboxSelected : UIImage.checkboxUnselected
    }
}

private extension RoutineCell {
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
            checkBox,
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
        checkBox.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
        }
        
        nameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(checkBox.snp.trailing).offset(12)
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
    
    // MARK: - setActions
    func setActions() {
        checkBox.gestureRecognizers?.forEach {
            checkBox.removeGestureRecognizer($0)
        }
        
        let tap = UITapGestureRecognizer()
        checkBox.addGestureRecognizer(tap)
        
        tap.rx.event
            .map { _ in () }
            .throttle(.milliseconds(200), scheduler: MainScheduler.instance)
            .bind(to: checkboxTapSubject)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: RoutineCell {
    var checkboxDidTap: ControlEvent<Void> {
        ControlEvent(events: base.checkboxTapSubject.asObservable())
    }
}
