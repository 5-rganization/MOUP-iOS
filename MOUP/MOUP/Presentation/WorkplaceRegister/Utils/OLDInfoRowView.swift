//
//  OLDInfoRowView.swift
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


final class OLDInfoRowView: UIView {
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
    
    /// Chevron 버튼의 탭 영역. 아이콘(7×12)이 아니라 손가락 크기에 맞춘다.
    private let chevronTapSize = CGSize(width: 44, height: 44)

    private let chevronButton = UIButton().then {
        $0.setImage(.chevronRight, for: .normal)
        $0.isUserInteractionEnabled = true
        // 버튼을 키워도 아이콘은 오른쪽 끝에 붙어 있어야 기존 위치가 유지된다.
        $0.contentHorizontalAlignment = .right
    }
    
    private let checkBox = UIButton().then {
        $0.setImage(.checkboxUnselected, for: .normal)
        $0.setImage(.checkboxSelected, for: .selected)
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
    
    func updateLabelValue(_ newValue: String) {
        guard case .labelWithChevron = rowType else { return }
        valueLabel.text = newValue
    }
    
    func updateTitle(to newTitle: String) {
        titleLabel.text = newTitle
    }
    
    func updateColorTitle(to title: String) {
        guard case .colorWithChevron = rowType else { return }
        titleLabel.text = title
    }
    
    func updateColorDot(with color: UIColor) {
        guard case .colorWithChevron = rowType else { return }
        colorDotView.backgroundColor = color
    }
    
    func updateButtonTitle(to title: String) {
        guard case .labelWithButton = rowType else { return }
        actionButton.setTitle(title, for: .normal)
    }
    
    func updateAttributedTitle(to newTitle: String,
                     font: UIFont = .headBold(18),
                     textColor: UIColor = .gray900,
                     asteriskColor: UIColor = .primary500) {
        let attributed = NSMutableAttributedString(string: newTitle)

        // 기본 스타일
        attributed.addAttribute(.font, value: font, range: NSRange(location: 0, length: newTitle.count))
        attributed.addAttribute(.foregroundColor, value: textColor, range: NSRange(location: 0, length: newTitle.count))

        // 별(*) 색상만 변경
        if let starRange = newTitle.range(of: "*") {
            let nsRange = NSRange(starRange, in: newTitle)
            attributed.addAttribute(.foregroundColor, value: asteriskColor, range: nsRange)
        }

        titleLabel.attributedText = attributed
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

private extension OLDInfoRowView {
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
            chevronButton.addTarget(self, action: #selector(didTapChevron), for: .touchUpInside)
            
        }
    }
    
    // MARK: - setConstraints
    func setConstraints(type: InfoRowType) {
        switch type {
        case .checkBox:
            titleLabel.snp.makeConstraints {
                $0.top.equalToSuperview().offset(12)
                $0.leading.equalToSuperview().offset(16)
                $0.bottom.equalToSuperview().inset(12)
            }
            
            checkBox.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().inset(16)
            }
            
        case .labelWithChevron:
            titleLabel.snp.makeConstraints {
                $0.top.equalToSuperview().offset(12)
                $0.leading.equalToSuperview().offset(16)
                $0.bottom.equalToSuperview().inset(12)
            }
            
            valueLabel.snp.makeConstraints {
                $0.centerY.equalTo(titleLabel)
                $0.trailing.equalTo(chevronButton.snp.leading).offset(-12)
            }
            
            chevronButton.snp.makeConstraints {
                $0.centerY.equalTo(titleLabel)
                $0.trailing.equalToSuperview().inset(16)
                // 크기를 안 주면 탭 영역이 이미지 크기(7×12)가 된다. 이 버튼이 Row의 유일한 탭 타깃이다.
                $0.size.equalTo(chevronTapSize)
            }
            
        case .labelWithButton:
            titleLabel.snp.makeConstraints {
                $0.top.equalToSuperview().offset(12)
                $0.leading.equalToSuperview().offset(16)
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
                $0.size.equalTo(chevronTapSize)
            }
        }
    }
}
extension Reactive where Base: OLDInfoRowView {
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
    
    var labelValue: Binder<String> {
        return Binder(base) { view, value in
            view.updateLabelValue(value)
        }
    }
    
    /// color title 업데이트 바인딩
    var colorTitle: Binder<String> {
        return Binder(base) { view, title in
            view.updateColorTitle(to: title)
        }
    }

    /// color dot 색상 바인딩
    var colorDot: Binder<UIColor> {
        return Binder(base) { view, color in
            view.updateColorDot(with: color)
        }
    }
    
    /// labelWithButton 타입의 버튼 타이틀 업데이트 바인딩
    var labelButtonTitle: Binder<String> {
        return Binder(base) { view, title in
            view.updateButtonTitle(to: title)
        }
    }
}

