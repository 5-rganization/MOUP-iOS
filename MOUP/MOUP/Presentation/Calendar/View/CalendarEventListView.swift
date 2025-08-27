//
//  CalendarEventListView.swift
//  MOUP
//
//  Created by 서동환 on 8/26/25.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

/// 근무 리스트 UI
final class CalendarEventListView: UIView {
    
    // MARK: - Properties
    fileprivate let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    /// 모달 핸들 UI
    private let grabberView = ModalGrabberView()
    /// 날짜(일) 라벨
    private let dayLabel = UILabel().then {
        $0.font = .headBold(20)
        $0.textColor = .gray900
    }
    /// 근무 리스트
    fileprivate let eventTableView = UITableView().then {
        $0.register(PersonalModeEventCell.self, forCellReuseIdentifier: PersonalModeEventCell.identifier)
        $0.register(SharedModeEventCell.self, forCellReuseIdentifier: SharedModeEventCell.identifier)
        
        $0.rowHeight = 84  // 64 + 16(셀 간격)
        $0.separatorStyle = .none
    }
    /// 근무 리스트에 아이템이 없을 때 표시되는 라벨
    private let emptyLabel = UILabel().then {
        $0.text = "등록된 근무 일정이 없어요"
        $0.textColor = .gray500
        $0.font = .bodyMedium(16)
        $0.textAlignment = .center
    }
    /// 근무 등록 버튼
    fileprivate let registerButton = BaseButton(title: "근무 등록하기")
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Internal Methods
    func update(day: Int) {
        dayLabel.text = "\(day)일"
    }
}

private extension CalendarEventListView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        self.addSubviews(grabberView,
                         dayLabel,
                         emptyLabel,
                         eventTableView,
                         registerButton)
    }
    
    // MARK: - setStyles
    func setStyles() {
        self.backgroundColor = .primaryBackground
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.gray400.cgColor
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        grabberView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.centerX.equalTo(self.safeAreaLayoutGuide)
            $0.width.equalTo(45)
            $0.height.equalTo(4)
        }
        
        dayLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(28)
            $0.leading.equalTo(self.safeAreaLayoutGuide).inset(16)
        }
        
        emptyLabel.snp.makeConstraints {
            $0.center.equalTo(eventTableView)
        }
        
        eventTableView.snp.makeConstraints {
            $0.top.equalTo(dayLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            $0.bottom.equalTo(registerButton.snp.top).offset(-12)
        }
        
        registerButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide).inset(16)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(12)
            $0.height.equalTo(45)
        }
    }
}

// MARK: - Extension Reactive
extension Reactive where Base: CalendarEventListView {
    var personalEventTableViewDataSource: Binder<[CalendarEvent]> {
        return Binder(base) { view, event in
            // RxSwift Delegate 오류 방지
            view.eventTableView.dataSource = nil
            view.eventTableView.delegate = nil
            
            Observable.just(event)
                .bind(to: view.eventTableView.rx.items(
                    cellIdentifier: PersonalModeEventCell.identifier,
                    cellType: PersonalModeEventCell.self
                )) { _, event, cell in
                    cell.update(event: event)
                }.disposed(by: base.disposeBag)
        }
    }
    var sharedEventTableViewDataSource: Binder<[CalendarEvent]> {
        return Binder(base) { view, event in
            // RxSwift Delegate 오류 방지
            view.eventTableView.dataSource = nil
            view.eventTableView.delegate = nil
            
            Observable.just(event)
                .bind(to: view.eventTableView.rx.items(
                    cellIdentifier: SharedModeEventCell.identifier,
                    cellType: SharedModeEventCell.self
                )) { _, event, cell in
                    cell.update(event: event)
                }.disposed(by: base.disposeBag)
        }
    }
    var eventTableViewModelSelected: ControlEvent<CalendarEvent> { base.eventTableView.rx.modelSelected(CalendarEvent.self) }
    var registerButtonTap: ControlEvent<Void> { base.registerButton.rx.tap }
}
