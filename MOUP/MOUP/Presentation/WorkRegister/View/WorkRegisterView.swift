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
    
    // MARK: - UI Components
    private let selectWorkplace = InfoRowView(title: "근무지 선택 *", type: .labelWithChevron(value: ""), frame: .zero)
    
    
    
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
            selectWorkplace
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        selectWorkplace.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().offset(4)
            $0.trailing.equalToSuperview()
        }
    }
    
    // MARK: - setBindings
    func setBindings() {
        selectWorkplace.rx.tap
            .bind(to: selectWorkplaceSubject)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: WorkRegisterView {
    var selectWorkplaceTap: ControlEvent<Void> {
        return ControlEvent(events: base.selectWorkplaceSubject.asObservable())
    }
}
