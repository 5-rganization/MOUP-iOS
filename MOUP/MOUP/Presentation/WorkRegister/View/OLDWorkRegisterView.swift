//
//  OLDWorkRegisterView.swift
//  MOUP
//
//  Created by 양원식 on 8/8/25.
//
import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class OLDWorkRegisterView: UIView {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    fileprivate let selectWorkplaceSubject = PublishSubject<Void>()
    fileprivate let dateTapSubject = PublishSubject<Void>()
    fileprivate let repetitionTapSubject = PublishSubject<Void>()
    fileprivate let clockInTapSubject = PublishSubject<Void>()
    fileprivate let clockOutTapSubject = PublishSubject<Void>()
    fileprivate let lunchBreakTapSubject = PublishSubject<Void>()
    fileprivate let routinTapSubject = PublishSubject<Void>()
    
    // MARK: - UI Components
    fileprivate let navigationBar = BaseNavigationBar(title: "새 근무 등록")
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .fill
        $0.distribution = .fill
    }
    
    private let selectWorkplace = OLDInfoRowView(title: "근무지 선택 *", type: .labelWithChevron(value: ""), frame: .zero).then {
        $0.updateAttributedTitle(to: "근무지 선택 *")
    }
    private let divider = UIView().then {
        $0.backgroundColor = .gray400
    }

    private let workDateContainerView = OLDWorkDateContainerView()
    private let workTimeContainerView = OLDWorkTimeContainerView()
    private let workRoutinContainerView = OLDWorkRoutinContainerView()
    private let memoContainerView = OLDMemoContainerView()
    
    private let registerButton = BaseButton(title: "등록하기").then {
        $0.isEnabled = false
    }
    
    var getNavigationBar: BaseNavigationBar { navigationBar }
    var getRegisterButton: BaseButton { registerButton }
    var getMemoContainerView: OLDMemoContainerView { memoContainerView }
    var getSelectWorkplace: OLDInfoRowView { selectWorkplace }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Public Methods
    func setWorkDateText(_ text: String) {
        workDateContainerView.setDateText(text)
    }
    
    func setClockInText(_ text: String) {
        workTimeContainerView.setClockInText(text)
    }
    func setClockOutText(_ text: String) {
        workTimeContainerView.setClockOutText(text)
    }
    func setLunchBreakText(_ text: String) {
        workTimeContainerView.setLunchBreakText(text)
    }
    
    func setRepetitionText(_ text: String) {
        workDateContainerView.setRepetitionText(text)
    }
    
    func updateRoutines(_ routines: [RoutineSummary]) {
        workRoutinContainerView.updateRoutines(routines)
    }
}

private extension OLDWorkRegisterView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setBindings()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            navigationBar,
            scrollView
        )
        
        scrollView.addSubviews(
            contentView
        )
        
        contentView.addSubviews(
            stackView,
            registerButton
        )
        
        stackView.addArrangedSubviews(
            selectWorkplace,
            divider,
            workDateContainerView,
            workTimeContainerView,
            workRoutinContainerView,
            memoContainerView
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalTo(safeAreaLayoutGuide)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.trailing.leading.equalTo(safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.horizontalEdges.equalToSuperview()
        }
        
        divider.snp.makeConstraints {
            $0.top.equalTo(selectWorkplace.snp.bottom)
            $0.height.equalTo(1)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        registerButton.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(69)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(contentView).inset(12)
            $0.height.equalTo(45)
        }
    }
    
    // MARK: - setBindings
    func setBindings() {
        selectWorkplace.rx.tap
            .bind(to: selectWorkplaceSubject)
            .disposed(by: disposeBag)
        
        workDateContainerView.rx.dateTap
            .bind(to: dateTapSubject)
            .disposed(by: disposeBag)
        
        workDateContainerView.rx.repetitionTap
            .bind(to: repetitionTapSubject)
            .disposed(by: disposeBag)
        
        workTimeContainerView.rx.clockInTap
            .bind(to: clockInTapSubject)
            .disposed(by: disposeBag)
        
        workTimeContainerView.rx.clockOutTap
            .bind(to: clockOutTapSubject)
            .disposed(by: disposeBag)
        
        workTimeContainerView.rx.lunchBreakTap
            .bind(to: lunchBreakTapSubject)
            .disposed(by: disposeBag)
        
        workRoutinContainerView.rx.routinTap
            .bind(to: routinTapSubject)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: OLDWorkRegisterView {
    var navBackBtnTapped: ControlEvent<Void> {
        return base.navigationBar.rx.backBtnTapped
    }
    
    var selectWorkplaceTap: ControlEvent<Void> {
        return ControlEvent(events: base.selectWorkplaceSubject.asObservable())
    }
    
    var workDateTap: ControlEvent<Void> {
        return ControlEvent(events: base.dateTapSubject.asObservable())
    }
    
    var repetitionTap: ControlEvent<Void> {
        return ControlEvent(events: base.repetitionTapSubject.asObservable())
    }
    
    var clockInTap: ControlEvent<Void> {
        return ControlEvent(events: base.clockInTapSubject.asObservable())
    }
    
    var clockOutTap: ControlEvent<Void> {
        return ControlEvent(events: base.clockOutTapSubject.asObservable())
    }
    
    var lunchBreakTap: ControlEvent<Void> {
        return ControlEvent(events: base.lunchBreakTapSubject.asObservable())
    }
    
    var routinTap: ControlEvent<Void> {
        return ControlEvent(events: base.routinTapSubject.asObservable())
    }

    var selectedWorkDateText: Binder<String> {
        Binder(base) { view, text in
            view.setWorkDateText(text)
        }
    }
    
    var selectedClockInTimeText: Binder<String> {
        Binder(base) { view, text in
            view.setClockInText(text)
        }
    }
    var selectedClockOutTimeText: Binder<String> {
        Binder(base) { view, text in
            view.setClockOutText(text)
        }
    }
    var selectedLunchBreakTimeText: Binder<String> {
        Binder(base) { view, text in
            view.setLunchBreakText(text)
        }
    }
    
    var selectedRoutines: Binder<[RoutineSummary]> {
        Binder(base) { view, routines in
            view.updateRoutines(routines)
        }
    }
}
