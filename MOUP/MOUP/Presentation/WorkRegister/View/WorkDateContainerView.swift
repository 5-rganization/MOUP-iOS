//
//  WorkDateContainerView.swift
//  MOUP
//
//  Created by 양원식 on 8/10/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

final class WorkDateContainerView: UIView {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    fileprivate let dateSubject = PublishSubject<Void>()
    fileprivate let repetitionSubject = PublishSubject<Void>()
    
    var dateTapObservable: Observable<Void> {
        return dateSubject.asObservable()
    }
    
    var repetitionTapObservable: Observable<Void> {
        return repetitionSubject.asObservable()
    }
    
    // MARK: - UI Components
    private let workDateTitle = UILabel().then {
        let fullText = "근무 날짜 *"
        let attributed = NSMutableAttributedString(string: fullText)

        attributed.addAttribute(.font, value: UIFont.headBold(18), range: NSRange(location: 0, length: fullText.count))
        attributed.addAttribute(.foregroundColor, value: UIColor.gray900, range: NSRange(location: 0, length: fullText.count))

        if let starRange = fullText.range(of: "*") {
            let nsRange = NSRange(starRange, in: fullText)
            attributed.addAttribute(.foregroundColor, value: UIColor.accent, range: nsRange)
        }

        $0.attributedText = attributed
    }
    
    private let date = InfoRowView(title: "날짜", type: .labelWithButton(title: "선택"), frame: .zero)
    private let repetition = InfoRowView(title: "반복", type: .labelWithChevron(value: "선택"), frame: .zero)
    
    private let container = ContainerView()
    private let divider = UIView().then {
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
    func setDateText(_ text: String) {
        date.updateButtonTitle(to: text)
    }

}

private extension WorkDateContainerView {
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
            workDateTitle,
            container
        )
        
        container.addSubviews(
            date,
            divider,
            repetition
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        workDateTitle.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
        }
        
        container.snp.makeConstraints {
            $0.top.equalTo(workDateTitle.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(repetition.snp.bottom)
        }
        
        date.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }
        
        divider.snp.makeConstraints {
            $0.top.equalTo(date.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        repetition.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
        }
        
        self.snp.makeConstraints {
            $0.bottom.equalTo(container.snp.bottom).offset(0)
        }
    }
    
    // MARK: - setBindings
    func setBindings() {
        date.rx.tap
            .bind(to: dateSubject)
            .disposed(by: disposeBag)
        
        repetition.rx.tap
            .bind(to: repetitionSubject)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: WorkDateContainerView {
    var dateTap: ControlEvent<Void> {
        return ControlEvent(events: base.dateSubject.asObservable())
    }
    
    var repetitionTap: ControlEvent<Void> {
        return ControlEvent(events: base.repetitionSubject.asObservable())
    }
    
    var selectedDateText: Binder<String> {
        Binder(base) { view, text in
            view.setDateText(text)
        }
    }
}



