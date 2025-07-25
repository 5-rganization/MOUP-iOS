//
//  MyPageView.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

enum MyPageMenu: String, CaseIterable {
    case account = "계정"
    case contact = "문의하기"
    case info = "정보"
}

final class MyPageView: UIView {
    
    // MARK: - Properties
    
    fileprivate let menuTappedSubject = PublishSubject<MyPageMenu>()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let profileImageFrame = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 40
        $0.backgroundColor = .primary50
    }
    
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.image = .worker
    }
    
    private let nicknameRoleStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .leading
    }
    
    private let nicknameLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.setLineSpacing(.bodyMedium)
        $0.text = "MOUP"
    }
    
    private let roleLabel = UILabel().then {
        $0.font = .bodyMedium(14)
        $0.setLineSpacing(.bodyMedium)
        $0.textColor = .gray700
        $0.text = "알바생"
    }
    
    fileprivate let editButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = UIImage.editButton
        
        $0.configuration = config
    }
    
    private let menuStackView = UIStackView().then {
        $0.axis = .vertical
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray400.cgColor
    }
    
    fileprivate let logoutButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .primary50
        config.baseForegroundColor = .primary600
        
        let attrTitle = AttributedString(
            "로그아웃",
            attributes: AttributeContainer([
                .font: UIFont.buttonSemibold(16)
            ])
        )
        config.attributedTitle = attrTitle
        
        $0.configuration = config
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.primary500.cgColor
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

private extension MyPageView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            profileImageFrame,
            nicknameRoleStackView,
            editButton,
            menuStackView,
            logoutButton
        )
        
        profileImageFrame.addSubview(profileImageView)
        
        nicknameRoleStackView.addArrangedSubviews(
            nicknameLabel,
            roleLabel
        )
        
        MyPageMenu.allCases.enumerated().forEach { index, menu in
            let row = MenuRowView(title: menu.rawValue)
            row.isLast = index == MyPageMenu.allCases.count - 1
            
            row.tap
                .map { menu }
                .bind(to: menuTappedSubject)
                .disposed(by: disposeBag)
            
            menuStackView.addArrangedSubview(row)
        }
    }
    
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        profileImageFrame.snp.makeConstraints {
            $0.size.equalTo(80)
            $0.top.equalTo(safeAreaLayoutGuide).offset(32)
            $0.leading.equalToSuperview().offset(16)
        }
        
        profileImageView.snp.makeConstraints {
            $0.width.equalTo(57)
            $0.height.equalTo(70)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(profileImageFrame.snp.bottom).offset(2)
        }
        
        nicknameRoleStackView.snp.makeConstraints {
            $0.centerY.equalTo(profileImageFrame.snp.centerY)
            $0.leading.equalTo(profileImageFrame.snp.trailing).offset(32)
        }
        
        editButton.snp.makeConstraints {
            $0.size.equalTo(44)
            $0.leading.equalTo(nicknameRoleStackView.snp.trailing).offset(4)
            $0.centerY.equalTo(nicknameLabel.snp.centerY)
        }
        
        menuStackView.snp.makeConstraints {
            $0.top.equalTo(profileImageFrame.snp.bottom).offset(32)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(16)
        }
        
        logoutButton.snp.makeConstraints {
            $0.top.equalTo(menuStackView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }
    }
}

extension Reactive where Base: MyPageView {
    var editButtonTapped: ControlEvent<Void> {
        base.editButton.rx.tap
    }
    
    var menuTapped: ControlEvent<MyPageMenu> {
        ControlEvent(events: base.menuTappedSubject)
    }
    
    var logoutButtonTapped: ControlEvent<Void> {
        base.logoutButton.rx.tap
    }
}
