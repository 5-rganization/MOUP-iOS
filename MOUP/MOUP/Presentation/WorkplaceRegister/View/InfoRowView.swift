//
//  InfoRowView.swift
//  MOUP
//
//  Created by 양원식 on 7/18/25.
//
import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

enum InfoRowType {
    case checkBox(isChecked: Bool)
    case labelWithChevron(value: String)
    case labelWithButton(title: String)
    case colorWithChevron(color: UIColor, title: String)
}


final class InfoRowView: UIView {
    // MARK: - Properties
    private let tapRelay = PublishRelay<Void>()
    
    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }
    
    private let valueLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray700
    }
    
    private let chevronButton = UIButton().then {
        $0.setImage(UIImage(named: "ChevronRight"), for: .normal)
        $0.isUserInteractionEnabled = true
    }
    
    private let checkBox = UIButton().then {
        $0.setImage(UIImage(named: "CheckboxUnselected"), for: .normal)
        $0.setImage(UIImage(named: "CheckboxSelected"), for: .selected)
    }
    
    private let actionButton = UIButton(configuration: .filled()).then {
        $0.configuration?.baseBackgroundColor = .primary100
        $0.configuration?.baseForegroundColor = .gray700
        $0.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
    }
    
    private let colorDotView = UIView().then {
        $0.backgroundColor = .labelRed
        $0.layer.cornerRadius = 6
        $0.clipsToBounds = true
    }
    
    private var rowType: InfoRowType?
    
    // MARK: - Initializer
    init(title: String, type: InfoRowType, frame: CGRect) {
        super.init(frame: frame)
        self.rowType = type
        self.titleLabel.text = title
        configure(type: type)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Getter
    var getCheckBox: UIButton { checkBox }
    var tap: Observable<Void> {
        tapRelay.asObservable()
    }
    
    // MARK: - Public Methods
    func setChecked(_ isChecked: Bool) {
        checkBox.isSelected = isChecked
    }
    
    func isChecked() -> Bool {
        return checkBox.isSelected
    }
    
    @objc private func didTapCheckBox() {
        tapRelay.accept(())
    }
    
    @objc private func didTapChevron() {
        tapRelay.accept(())
    }
    
    @objc private func didTapActionButton() {
        tapRelay.accept(())
    }
}

private extension InfoRowView {
    // MARK: - configure
    func configure(type: InfoRowType) {
        setHierarchy(type: type)
        setStyles(type: type)
        setConstraints(type: type)
    }
    
    // MARK: - setHierarchy
    func setHierarchy(type: InfoRowType) {
        switch type {
        case .checkBox:
            addSubviews(titleLabel, checkBox)
            
        case .labelWithChevron:
            addSubviews(titleLabel, valueLabel, chevronButton)
            
        case .labelWithButton:
            addSubviews(titleLabel, actionButton)
            
        case .colorWithChevron:
            addSubviews(colorDotView, titleLabel, chevronButton)
        }
    }
    
    // MARK: - setStyles
    func setStyles(type: InfoRowType) {
        switch type {
        case .checkBox(let isChecked):
            checkBox.isSelected = isChecked
            checkBox.addTarget(self, action: #selector(didTapCheckBox), for: .touchUpInside)
        case .labelWithChevron(let value):
            valueLabel.text = value
            chevronButton.addTarget(self, action: #selector(didTapChevron), for: .touchUpInside)
        case .labelWithButton(let title):
            actionButton.setTitle(title, for: .normal)
            actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
        case .colorWithChevron(let color, let title):
            colorDotView.backgroundColor = color
            titleLabel.text = title
            
        }
    }
    
    // MARK: - setConstraints
    func setConstraints(type: InfoRowType) {
        switch type {
        case .checkBox:
            titleLabel.snp.makeConstraints {
                $0.top.equalToSuperview().offset(12)
                $0.leading.equalToSuperview().offset(12)
                $0.bottom.equalToSuperview().inset(12)
            }
            
            checkBox.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().inset(16)
            }
            
        case .labelWithChevron:
            titleLabel.snp.makeConstraints {
                $0.top.equalToSuperview().offset(12)
                $0.leading.equalToSuperview().offset(12)
                $0.bottom.equalToSuperview().inset(12)
            }
            
            valueLabel.snp.makeConstraints {
                $0.centerY.equalTo(titleLabel)
                $0.trailing.equalTo(chevronButton.snp.leading).offset(-12)
            }
            
            chevronButton.snp.makeConstraints {
                $0.centerY.equalTo(titleLabel)
                $0.trailing.equalToSuperview().inset(16)
            }
            
        case .labelWithButton:
            titleLabel.snp.makeConstraints {
                $0.top.equalToSuperview().offset(12)
                $0.leading.equalToSuperview().offset(12)
                $0.bottom.equalToSuperview().inset(12)
            }
            
            actionButton.snp.makeConstraints {
                $0.trailing.equalToSuperview().inset(16)
                $0.centerY.equalToSuperview()
            }
            
        case .colorWithChevron:
            colorDotView.snp.makeConstraints {
                $0.width.height.equalTo(12)
                $0.centerY.equalToSuperview()
                $0.leading.equalToSuperview().offset(16)
            }
            
            titleLabel.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalTo(colorDotView.snp.trailing).offset(6)
                $0.bottom.equalToSuperview().inset(12)
            }
            
            chevronButton.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().inset(16)
            }
        }
    }
}
extension Reactive where Base: InfoRowView {
    /// 버튼 탭 이벤트
    var tap: ControlEvent<Void> {
        return ControlEvent(events: base.tap)
    }

    /// 체크박스 선택 상태 바인딩
    var isChecked: Binder<Bool> {
        return Binder(base) { view, isChecked in
            view.setChecked(isChecked)
        }
    }
}

