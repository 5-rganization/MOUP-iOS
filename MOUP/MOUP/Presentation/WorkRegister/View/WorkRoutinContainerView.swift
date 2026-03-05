//
//  WorkRoutinContainerView.swift
//  MOUP
//
//  Created by 양원식 on 8/11/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

final class WorkRoutinContainerView: UIView {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    fileprivate let routinSubject = PublishSubject<Void>()
    
    var routinTapObservable: Observable<Void> {
        return routinSubject.asObservable()
    }
    
    // MARK: - UI Components
    private let routinTitle = UILabel().then {
        $0.text = "루틴"
        $0.textColor = .gray900
        $0.font = .headBold(18)
    }
    
    private let routin = OLDInfoRowView(title: "루틴 추가", type: .labelWithChevron(value: ""), frame: .zero)
    
    private let container = OLDContainerView()
    
    private let additionalRoutineLabel = UILabel().then {
        $0.text = ""
        $0.textColor = .gray700
        $0.font = .fieldsRegular(16)
        $0.isHidden = true
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
    
    func updateRoutines(_ routines: [RoutineSummary]) {
        let count = routines.count
        let isSelected = count > 0
        
        if isSelected {
            let firstName = routines.first?.routineName ?? "루틴 선택 완료"
            routin.updateTitle(to: firstName)
            
            if count > 1 {
                additionalRoutineLabel.text = "+ \(count - 1)"
                additionalRoutineLabel.isHidden = false
            } else {
                additionalRoutineLabel.isHidden = true
            }
        } else {
            routin.updateTitle(to: "루틴 추가")
            additionalRoutineLabel.isHidden = true
        }
    }
}

private extension WorkRoutinContainerView {
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
            routinTitle,
            container
            )
        
        container.addSubviews(
            routin,
            additionalRoutineLabel
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        routinTitle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(16)
        }
        
        container.snp.makeConstraints {
            $0.top.equalTo(routinTitle.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(routin.snp.bottom)
        }
        
        routin.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }
        
        additionalRoutineLabel.snp.makeConstraints {
            $0.centerY.equalTo(routin)
            $0.trailing.equalTo(routin.snp.trailing).offset(-52)
        }
        
        self.snp.makeConstraints {
            $0.bottom.equalTo(container.snp.bottom).offset(0)
        }
    }
    
    // MARK: - setBindings
    func setBindings() {
        routin.rx.tap
            .bind(to: routinSubject)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: WorkRoutinContainerView {
    var routinTap: ControlEvent<Void> {
        return ControlEvent(events: base.routinSubject.asObservable())
    }
}
