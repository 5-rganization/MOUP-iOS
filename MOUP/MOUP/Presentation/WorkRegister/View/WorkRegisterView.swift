//
//  WorkRegisterView.swift
//  MOUP
//
//  Created by 양원식 on 8/8/25.
//
import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class WorkRegisterView: UIView {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    fileprivate let selectWorkplaceSubject = PublishSubject<Void>()
    fileprivate let dateTapSubject = PublishSubject<Void>()
    fileprivate let repetitionTapSubject = PublishSubject<Void>()
    fileprivate let clockInTapSubject = PublishSubject<Void>()
    fileprivate let clockOutTapSubject = PublishSubject<Void>()
    fileprivate let lunchBreakTapSubject = PublishSubject<Void>()
    fileprivate let routinTapSubject = PublishSubject<Void>()
    fileprivate let colorTapSubject = PublishSubject<Void>()
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .fill
        $0.distribution = .fill
    }
    
    private let selectWorkplace = InfoRowView(title: "근무지 선택", type: .labelWithChevron(value: ""), frame: .zero)
    private let workDateContainerView = WorkDateContainerView()
    private let workTimeContainerView = WorkTimeContainerView()
    private let workRoutinContainerView = WorkRoutinContainerView()
    private let colorLabelContainerView = ColorLabelContainerView()
    private let memoContainerView = MemoContainerView()
    
    private let registerButton = BaseButton(title: "등록하기", isSecondary: true)
    
    
    
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
}

private extension WorkRegisterView {
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
            workDateContainerView,
            workTimeContainerView,
            workRoutinContainerView,
            colorLabelContainerView,
            memoContainerView
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.horizontalEdges.equalToSuperview()
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
        
        colorLabelContainerView.rx.colorLabelInfoRowTap
            .bind(to: colorTapSubject)
            .disposed(by: disposeBag)
        
    }
}

extension Reactive where Base: WorkRegisterView {
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
    
    var colorTap: ControlEvent<Void> {
        return ControlEvent(events: base.colorTapSubject.asObservable())
    }
    
    var selectedWorkDateText: Binder<String> {
        Binder(base) { view, text in
            view.setWorkDateText(text)
        }
    }
}
