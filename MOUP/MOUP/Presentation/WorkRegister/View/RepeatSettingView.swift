//
//  RepeatSettingView.swift
//  MOUP
//
//  Created by 양원식 on 11/15/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class RepeatSettingView: UIView {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    fileprivate let dateTapSubject = PublishSubject<Void>()
    fileprivate let dayTapSubject = PublishSubject<Int>()
    fileprivate let registerTapSubject = PublishSubject<Void>()
    
    private var daySelections: [Bool] = Array(repeating: false, count: 7)
    
    // MARK: - UI Components
    fileprivate let navigationBar = BaseNavigationBar(title: "반복")
    
    private let dayStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.distribution = .fillEqually
    }
    
    private lazy var dayButtons: [RadioButtonView] = [
        RadioButtonView(title: "일요일마다", type: .none(selectedRadioButton: .check, unselectedRadioButton: nil)),
        RadioButtonView(title: "월요일마다", type: .none(selectedRadioButton: .check, unselectedRadioButton: nil)),
        RadioButtonView(title: "화요일마다", type: .none(selectedRadioButton: .check, unselectedRadioButton: nil)),
        RadioButtonView(title: "수요일마다", type: .none(selectedRadioButton: .check, unselectedRadioButton: nil)),
        RadioButtonView(title: "목요일마다", type: .none(selectedRadioButton: .check, unselectedRadioButton: nil)),
        RadioButtonView(title: "금요일마다", type: .none(selectedRadioButton: .check, unselectedRadioButton: nil)),
        RadioButtonView(title: "토요일마다", type: .none(selectedRadioButton: .check, unselectedRadioButton: nil))
    ]
    
    private let dateTitleLabel = UILabel().then {
        $0.text = "반복 종료 날짜를 입력해주세요"
        $0.font = .headBold(18)
        $0.textColor = .gray900
    }
    
    private let container = ContainerView()
    private let dateRow = InfoRowView(title: "날짜", type: .labelWithButton(title: "선택"), frame: .zero)
    
    let registerButton = BaseButton(title: "등록하기")

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func updateDateText(_ text: String) {
        dateRow.updateButtonTitle(to: text)
    }
    
    func currentSelectedDays() -> [Int] {
        return daySelections.enumerated().compactMap { $1 ? $0 : nil }
    }
    
    func updateSelectedDays(_ set: Set<Int>) {
        // 내부 상태 업데이트
        for i in 0..<daySelections.count {
            daySelections[i] = set.contains(i)
        }
        
        // UI 업데이트
        for (index, button) in dayButtons.enumerated() {
            button.setSelected(daySelections[index])
        }
    }
}



// MARK: - Configure UI
private extension RepeatSettingView {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setBindings()
    }
    
    func setHierarchy() {
        addSubviews(
            navigationBar,
            dayStackView,
            dateTitleLabel,
            container,
            registerButton
        )
        
        dayButtons.forEach { dayStackView.addArrangedSubview($0) }
        
        container.addSubviews(
            dateRow
        )
    }
    
    func setStyles() {
        backgroundColor = .white
        registerButton.layer.cornerRadius = 10
    }
    
    func setConstraints() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalTo(safeAreaLayoutGuide)
        }
        
        dayStackView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }

        dateTitleLabel.snp.makeConstraints {
            $0.top.equalTo(dayStackView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(16)
        }
        
        container.snp.makeConstraints {
            $0.top.equalTo(dateTitleLabel.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }
        
        dateRow.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }

        registerButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(52)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(12)
        }
    }
    
    func setBindings() {
        // 날짜 선택
        dateRow.rx.tap
            .bind(to: dateTapSubject)
            .disposed(by: disposeBag)
        
        // 요일 선택 (toggle)
        for (index, button) in dayButtons.enumerated() {
            button.rx.tap
                .bind(onNext: { [weak self] in
                    guard let self else { return }
                    self.daySelections[index].toggle()
                    button.setSelected(self.daySelections[index])
                    self.dayTapSubject.onNext(index)
                })
                .disposed(by: disposeBag)
        }
        
        registerButton.rx.tap
            .bind(to: registerTapSubject)
            .disposed(by: disposeBag)
    }
}
extension Reactive where Base: RepeatSettingView {
    var navBackBtnTapped: ControlEvent<Void> {
        return base.navigationBar.rx.backBtnTapped
    }
    
    var dateTap: ControlEvent<Void> {
        ControlEvent(events: base.dateTapSubject.asObservable())
    }
    
    var dayTap: ControlEvent<Int> {
        ControlEvent(events: base.dayTapSubject.asObservable())
    }

    var registerTap: ControlEvent<Void> {
        ControlEvent(events: base.registerTapSubject.asObservable())
    }
}
