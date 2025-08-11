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
    
    private let routin = InfoRowView(title: "루틴 추가", type: .labelWithChevron(value: ""), frame: .zero)
    
    private let container = ContainerView()
    
    
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
            routin
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        routinTitle.snp.makeConstraints {
            $0.top.equalToSuperview()
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
