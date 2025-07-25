//
//  MenuRowView.swift
//  MOUP
//
//  Created by shinyoungkim on 7/25/25.
//

import UIKit
import Then
import SnapKit
import RxSwift

final class MenuRowView: UIView {
    
    // MARK: - Properties
    
    private let tapGesture = UITapGestureRecognizer()
    private let tapSubject = PublishSubject<Void>()
    
    var isLast: Bool = false {
        didSet {
            separatorView.isHidden = isLast
        }
    }
    
    var tap: Observable<Void> {
        tapSubject.asObservable()
    }

    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }
    
    private let rightArrow = UIImageView().then {
        $0.image = .myPageChevronRight
        $0.contentMode = .scaleAspectFit
    }
    
    private let separatorView = UIView().then {
        $0.backgroundColor = .gray400
    }
    
    // MARK: - Initializer
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MenuRowView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setConstraints()
        setGestures()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            titleLabel,
            rightArrow,
            separatorView
        )
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        self.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        rightArrow.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        separatorView.snp.makeConstraints {
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    // MARK: - setGestures
    func setGestures() {
        addGestureRecognizer(tapGesture)
        
        tapGesture.addTarget(
            self,
            action: #selector(handleTap)
        )
    }
    
    @objc func handleTap() {
        tapSubject.onNext(())
    }
}
