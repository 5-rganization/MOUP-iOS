//
//  OwnerWorkRegisterView.swift
//  MOUP
//
//  Created by 양원식 on 8/8/25.
//
import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class OwnerWorkRegisterView: UIView {
    // MARK: - Properties
    private let toggleSegment = RoleSegmentedControl(items: UserRole.allCases.map { $0.displayStr })
    
    private let disposeBag = DisposeBag()
    fileprivate let selectWorkplaceSubject = PublishSubject<Void>()
    fileprivate let dateTapSubject = PublishSubject<Void>()
    fileprivate let repetitionTapSubject = PublishSubject<Void>()
    fileprivate let clockInTapSubject = PublishSubject<Void>()
    fileprivate let clockOutTapSubject = PublishSubject<Void>()
    fileprivate let lunchBreakTapSubject = PublishSubject<Void>()
    fileprivate let routineTapSubject = PublishSubject<Void>()
    
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
    
    private let selectWorkplace = InfoRowView(title: "근무지 선택 *", type: .labelWithChevron(value: ""), frame: .zero).then {
        $0.updateAttributedTitle(to: "근무지 선택 *")
    }
    private let divider = UIView().then {
        $0.backgroundColor = .gray400
    }
    
    private let workerTitle = UILabel().then {
        let fullText = "근무자 *"
        let attributed = NSMutableAttributedString(string: fullText)

        attributed.addAttribute(.font, value: UIFont.headBold(18), range: NSRange(location: 0, length: fullText.count))
        attributed.addAttribute(.foregroundColor, value: UIColor.gray900, range: NSRange(location: 0, length: fullText.count))

        if let starRange = fullText.range(of: "*") {
            let nsRange = NSRange(starRange, in: fullText)
            attributed.addAttribute(.foregroundColor, value: UIColor.accent, range: nsRange)
        }

        $0.attributedText = attributed
    }
    
    private let repetition = InfoRowView(title: "인원 선택", type: .labelWithChevron(value: ""), frame: .zero)
    private let container = ContainerView()

    private let workDateContainerView = WorkDateContainerView()
    private let workTimeContainerView = WorkTimeContainerView()
    private let workRoutinContainerView = WorkRoutinContainerView()
    private let memoContainerView = MemoContainerView()
    
    private let registerButton = BaseButton(title: "등록하기").then {
        $0.isEnabled = false
    }
    
    var getRoleSegmentedControl: RoleSegmentedControl { toggleSegment }
    var getRegisterButton: BaseButton { registerButton }
    var getMemoContainerView: MemoContainerView { memoContainerView }
    var getSelectWorkplace: InfoRowView { selectWorkplace }
    
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
    
    // MARK: - Show/Hide Worker UI
    func showWorkerSection(_ show: Bool) {
        workerTitle.isHidden = !show
        container.isHidden = !show
    }
}

private extension OwnerWorkRegisterView {
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
            toggleSegment,
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
            workerTitle,
            container,
            workDateContainerView,
            workTimeContainerView,
            workRoutinContainerView,
            memoContainerView
        )
        
        container.addSubviews(
            repetition
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
        
        toggleSegment.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(32)
            $0.leading.trailing.equalTo(safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(48)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(toggleSegment.snp.bottom).offset(12)
            $0.leading.trailing.equalTo(safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }
        
        divider.snp.makeConstraints {
            $0.top.equalTo(selectWorkplace.snp.bottom)
            $0.height.equalTo(1)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        container.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }
        
        repetition.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
            .bind(to: routineTapSubject)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: OwnerWorkRegisterView {
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
        return ControlEvent(events: base.routineTapSubject.asObservable())
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
