//
//  InfoView.swift
//  MOUP
//
//  Created by shinyoungkim on 8/11/25.
//

import UIKit
import RxSwift
import RxCocoa

enum InfoMenu: String, CaseIterable {
    case termsOfService = "이용약관"
    case privacyPolicy = "개인정보처리방침"
    case openSourceLicense = "오픈소스 라이센스"
}

final class InfoView: UIView {
    
    // MARK: - Properties
    
    fileprivate let menuTappedSubject = PublishSubject<InfoMenu>()
    private let disposeBag = DisposeBag()

    // MARK: - UI Components
    
    fileprivate let navigationBar = BaseNavigationBar(title: "정보")
    
    private let menuStackView = UIStackView().then {
        $0.axis = .vertical
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray400.cgColor
    }
    
    private let appVersionTitleLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.setLineSpacing(.bodyMedium)
        $0.textColor = UIColor.gray900
        $0.text = "앱 버전"
    }
    
    private let appVersionLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.setLineSpacing(.bodyMedium)
        $0.textColor = UIColor.gray700
        $0.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    private let appVersionView = UIView().then {
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

private extension InfoView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            navigationBar,
            menuStackView,
            appVersionView
        )
        
        InfoMenu.allCases.enumerated().forEach { index, menu in
            let row = MenuRowView(title: menu.rawValue)
            row.isLast = index == InfoMenu.allCases.count - 1
            
            row.tap
                .map { menu }
                .bind(to: menuTappedSubject)
                .disposed(by: disposeBag)
            
            menuStackView.addArrangedSubview(row)
        }
        
        appVersionView.addSubviews(
            appVersionTitleLabel,
            appVersionLabel
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
        
        menuStackView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(32)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(16)
        }
        
        appVersionTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        appVersionLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        appVersionView.snp.makeConstraints {
            $0.top.equalTo(menuStackView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }
    }
}

extension Reactive where Base: InfoView {
    var backButtonTapped: ControlEvent<Void> {
        base.navigationBar.rx.backBtnTapped
    }
    
    var menuTapped: ControlEvent<InfoMenu> {
        ControlEvent(events: base.menuTappedSubject)
    }
}
