//
//  CalendarWorkListView.swift
//  MOUP
//
//  Created by 서동환 on 8/26/25.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

/// `CalendarWorkListView`의 이벤트를 `CalendarWorkListModalViewController`에 전달하는 Delegate
protocol CalendarWorkListViewDelegate: AnyObject {
    /// 근무 수정
    func editWork(work: WorkSummary)
    /// 단일 근무 삭제
    func deleteSingleWork(workId: Int)
    /// 반복 근무 삭제
    func deleteRecurringWork(workId: Int)
}

/// 근무 리스트 UI
final class CalendarWorkListView: UIView {
    
    // MARK: - Properties
    fileprivate let disposeBag = DisposeBag()
    
    // Property Injections
    weak var delegate: CalendarWorkListViewDelegate?
    
    // MARK: - UI Components
    /// 모달 핸들 UI
    private let grabberView = ModalGrabberView()
    /// 날짜(일) 라벨
    private let dayLabel = UILabel().then {
        $0.font = .headBold(20)
        $0.textColor = .gray900
    }
    /// 근무 리스트
    fileprivate let workTableView = UITableView().then {
        $0.register(PersonalModeWorkCell.self, forCellReuseIdentifier: PersonalModeWorkCell.identifier)
        $0.register(SharedModeWorkCell.self, forCellReuseIdentifier: SharedModeWorkCell.identifier)
        
        $0.rowHeight = 80  // 68 + 12(셀 간격)
        $0.separatorStyle = .none
    }
    /// 근무 리스트에 아이템이 없을 때 표시되는 라벨
    fileprivate let emptyLabel = UILabel().then {
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

private extension CalendarWorkListView {
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
                         workTableView,
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
            $0.center.equalTo(workTableView)
        }
        
        workTableView.snp.makeConstraints {
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
extension Reactive where Base: CalendarWorkListView {
    var personalWorkTableViewDataSource: Binder<[WorkSummary]> {
        return Binder(base) { view, work in
            // RxSwift Delegate 오류 방지
            view.workTableView.dataSource = nil
            view.workTableView.delegate = nil
            
            Observable.just(work)
                .bind(to: view.workTableView.rx.items(
                    cellIdentifier: PersonalModeWorkCell.identifier,
                    cellType: PersonalModeWorkCell.self
                )) { _, work, cell in
                    let editAction = UIAction(title: "수정하기") { _ in
                        base.delegate?.editWork(work: work)
                    }
                    let singleDeleteAction = UIAction(title: "삭제하기", attributes: .destructive) { _ in
                        base.delegate?.deleteSingleWork(workId: work.id)
                    }
                    let recurringDeleteAction = UIAction(title: "이후 모든 근무 삭제", attributes: .destructive) { _ in
                        base.delegate?.deleteRecurringWork(workId: work.id)
                    }
                    if work.repeatDays.isEmpty {
                        cell.menuButton.menu = UIMenu(children: [editAction, singleDeleteAction])
                    } else {
                        singleDeleteAction.title = "이 근무만 삭제"
                        let deleteSubMenu = UIMenu(title: "삭제하기", options: .destructive, children: [singleDeleteAction, recurringDeleteAction])
                        cell.menuButton.menu = UIMenu(children: [editAction, deleteSubMenu])
                    }
                    
                    cell.update(work: work)
                }.disposed(by: base.disposeBag)
        }
    }
    var sharedWorkTableViewDataSource: Binder<[WorkSummary]> {
        return Binder(base) { view, work in
            // RxSwift Delegate 오류 방지
            view.workTableView.dataSource = nil
            view.workTableView.delegate = nil
            
            Observable.just(work)
                .bind(to: view.workTableView.rx.items(
                    cellIdentifier: SharedModeWorkCell.identifier,
                    cellType: SharedModeWorkCell.self
                )) { _, work, cell in
                    let editAction = UIAction(title: "수정하기") { _ in
                        base.delegate?.editWork(work: work)
                    }
                    let singleDeleteAction = UIAction(title: "삭제하기", attributes: .destructive) { _ in
                        base.delegate?.deleteSingleWork(workId: work.id)
                    }
                    let recurringDeleteAction = UIAction(title: "이후 모든 근무 삭제", attributes: .destructive) { _ in
                        base.delegate?.deleteRecurringWork(workId: work.id)
                    }
                    if work.repeatDays.isEmpty {
                        cell.menuButton.menu = UIMenu(children: [editAction, singleDeleteAction])
                    } else {
                        singleDeleteAction.title = "이 근무만 삭제"
                        let deleteSubMenu = UIMenu(title: "삭제하기", options: .destructive, children: [singleDeleteAction, recurringDeleteAction])
                        cell.menuButton.menu = UIMenu(children: [editAction, deleteSubMenu])
                    }
                    
                    cell.update(work: work)
                }.disposed(by: base.disposeBag)
        }
    }
    var workTableViewModelSelected: ControlEvent<WorkSummary> { base.workTableView.rx.modelSelected(WorkSummary.self) }
    var workTableViewIsHidden: Binder<Bool> { base.workTableView.rx.isHidden }
    var emptyLabelIsHidden: Binder<Bool> { base.emptyLabel.rx.isHidden }
    var registerButtonTap: ControlEvent<Void> { base.registerButton.rx.tap }
}
