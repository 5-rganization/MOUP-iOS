//
//  AccountView.swift
//  MOUP
//
//  Created by shinyoungkim on 7/25/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

final class AccountView: UIView {
    
    // MARK: - Properties
    
    fileprivate let deleteAccountTappedSubject = PublishSubject<Void>()
    var deleteAccountTapped: Observable<Void> {
        deleteAccountTappedSubject.asObservable()
    }
    
    private let tapGesture = UITapGestureRecognizer()
    
    // MARK: - UI Components
    
    private let navigationBar = BaseNavigationBar(title: "계정")
    
    private let deleteAccountLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .deleteAccountLabel
        $0.text = "탈퇴하기"
    }
    
    private let rightArrow = UIImageView().then {
        $0.image = .myPageChevronRight
        $0.contentMode = .scaleAspectFit
    }
    
    private let deleteAccountView = UIView().then {
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray400.cgColor
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension AccountView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setGestures()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            navigationBar,
            deleteAccountView
        )
        
        deleteAccountView.addSubviews(
            deleteAccountLabel,
            rightArrow
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
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide)
        }
        
        deleteAccountView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(32)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(48)
        }
        
        deleteAccountLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        rightArrow.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
    }
    
    // MARK: - setGestures
    func setGestures() {
        deleteAccountView.addGestureRecognizer(tapGesture)
        tapGesture.addTarget(
            self,
            action: #selector(handleDeleteTap)
        )
    }
    
    @objc func handleDeleteTap() {
        deleteAccountTappedSubject.onNext(())
    }
}

extension Reactive where Base: AccountView {
    var deleteAccountTapped: ControlEvent<Void> {
        ControlEvent(events: base.deleteAccountTapped)
    }
}
