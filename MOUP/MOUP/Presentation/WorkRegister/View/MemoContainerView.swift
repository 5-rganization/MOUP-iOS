//
//  memoContainerView.swift
//  MOUP
//
//  Created by 양원식 on 8/11/25.
//

import UIKit
import Then
import RxSwift
import RxCocoa

final class MemoContainerView: UIView {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    fileprivate let maxLength = 150
    
    // MARK: - UI Components
    private let memoTitle = UILabel().then {
        $0.text = "메모"
        $0.textColor = .gray900
        $0.font = .headBold(18)
    }
    
    private let container = ContainerView()
    fileprivate let memoTextView = UITextView().then {
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .label
        $0.backgroundColor = .clear
        $0.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        $0.textContainer.lineFragmentPadding = 0
        $0.isScrollEnabled = true
        $0.textContainer.lineBreakMode = .byCharWrapping
    }

    fileprivate let placeholderLabel = UILabel().then {
        $0.text = "추가적인 내용을 입력해주세요"
        $0.textColor = .systemGray3
        $0.font = .systemFont(ofSize: 16)
        $0.isUserInteractionEnabled = false
    }
    
    fileprivate let counterLabel = UILabel().then {
        $0.text = "0/150"
        $0.font = .fieldsRegular(16)
        $0.textColor = .systemGray2
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
}

private extension MemoContainerView {
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
            memoTitle,
            container
        )
        
        container.addSubviews(
            memoTextView,
            counterLabel
        )
        
        memoTextView.addSubview(
            placeholderLabel
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        memoTitle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(16)
        }
        container.snp.makeConstraints {
            $0.top.equalTo(memoTitle.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(156)
        }
        
        memoTextView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(counterLabel.snp.top).offset(-8)
        }

        counterLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(10)
        }

        placeholderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.equalToSuperview().inset(16)
        }
        
        self.snp.makeConstraints {
            $0.bottom.equalTo(container.snp.bottom)
        }
    }
    
    // MARK: - setBindings
    func setBindings() {
        memoTextView.rx.didChange
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                let text = owner.memoTextView.text ?? ""
                if text.count > owner.maxLength {
                    let limited = String(text.prefix(owner.maxLength))
                    owner.memoTextView.text = limited
                }
                let count = owner.memoTextView.text?.count ?? 0
                owner.counterLabel.text = "\(count)/\(owner.maxLength)"
                owner.placeholderLabel.isHidden = count > 0
            })
            .disposed(by: disposeBag)
    }
}
extension Reactive where Base: MemoContainerView {
    var text: ControlProperty<String> {
        let source = base.memoTextView.rx.text.orEmpty

        let binder = Binder<String>(base) { view, text in
            view.memoTextView.text = text
            view.placeholderLabel.isHidden = !text.isEmpty
            view.counterLabel.text = "\(text.count)/\(view.maxLength)"
        }

        return ControlProperty(values: source, valueSink: binder)
    }
}


