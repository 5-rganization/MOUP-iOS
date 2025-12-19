//
//  WorkTimeContainerView.swift
//  MOUP
//
//  Created by 양원식 on 8/11/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

final class WorkTimeContainerView: UIView {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    fileprivate let clockInSubject = PublishSubject<Void>()
    fileprivate let clockOutSubject = PublishSubject<Void>()
    fileprivate let lunchBreakSubject = PublishSubject<Void>()
    
    var clockInTapObservable: Observable<Void> {
        return clockInSubject.asObservable()
    }
    
    var clockOutTapObservable: Observable<Void> {
        return clockOutSubject.asObservable()
    }
    
    var lunchBreakTapObservable: Observable<Void> {
        return lunchBreakSubject.asObservable()
    }
    
    // MARK: - UI Components
    private let workTimeTitle = UILabel().then {
        let fullText = "근무 시간 *"
        let attributed = NSMutableAttributedString(string: fullText)

        attributed.addAttribute(.font, value: UIFont.headBold(18), range: NSRange(location: 0, length: fullText.count))
        attributed.addAttribute(.foregroundColor, value: UIColor.gray900, range: NSRange(location: 0, length: fullText.count))

        if let starRange = fullText.range(of: "*") {
            let nsRange = NSRange(starRange, in: fullText)
            attributed.addAttribute(.foregroundColor, value: UIColor.accent, range: nsRange)
        }

        $0.attributedText = attributed
    }
    
    private let clockIn = InfoRowView(title: "출근", type: .labelWithButton(title: "선택"), frame: .zero)
    private let clockOut = InfoRowView(title: "퇴근", type: .labelWithButton(title: "선택"), frame: .zero)
    private let lunchBreak = InfoRowView(title: "휴게", type: .labelWithButton(title: "없음"), frame: .zero)
    
    private let container = ContainerView()
    private let divider = UIView().then {
        $0.backgroundColor = .gray400
    }
    
    private let divider1 = UIView().then {
        $0.backgroundColor = .gray400
    }
    
    
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
    func setClockInText(_ text: String) {
        clockIn.updateButtonTitle(to: text)
    }

    func setClockOutText(_ text: String) {
        clockOut.updateButtonTitle(to: text)
    }

    func setLunchBreakText(_ text: String) {
        lunchBreak.updateButtonTitle(to: text)
    }
}

private extension WorkTimeContainerView {
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
            workTimeTitle,
            container
            )
        
        container.addSubviews(
            clockIn,
            divider,
            clockOut,
            divider1,
            lunchBreak
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        workTimeTitle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(16)
        }
        
        container.snp.makeConstraints {
            $0.top.equalTo(workTimeTitle.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(lunchBreak.snp.bottom)
        }
        
        clockIn.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }
        
        divider.snp.makeConstraints {
            $0.top.equalTo(clockIn.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        clockOut.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
        }
        
        divider1.snp.makeConstraints {
            $0.top.equalTo(clockOut.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        lunchBreak.snp.makeConstraints {
            $0.top.equalTo(divider1.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
        }
        
        self.snp.makeConstraints {
            $0.bottom.equalTo(container.snp.bottom).offset(0)
        }
    }
    
    // MARK: - setBindings
    func setBindings() {
        clockIn.rx.tap
            .bind(to: clockInSubject)
            .disposed(by: disposeBag)
        
        clockOut.rx.tap
            .bind(to: clockOutSubject)
            .disposed(by: disposeBag)
        
        lunchBreak.rx.tap
            .bind(to: lunchBreakSubject)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: WorkTimeContainerView {
    var clockInTap: ControlEvent<Void> {
        return ControlEvent(events: base.clockInSubject.asObservable())
    }
    
    var clockOutTap: ControlEvent<Void> {
        return ControlEvent(events: base.clockOutSubject.asObservable())
    }
    
    var lunchBreakTap: ControlEvent<Void> {
        return ControlEvent(events: base.lunchBreakSubject.asObservable())
    }
}



