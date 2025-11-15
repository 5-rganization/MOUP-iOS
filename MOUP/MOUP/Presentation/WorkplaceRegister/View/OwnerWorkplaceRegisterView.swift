//
//  OwnerWorkplaceRegisterView.swift
//  MOUP
//
//  Created by 양원식 on 7/15/25.
//

import UIKit
import SnapKit
import Then

final class OwnerWorkplaceRegisterView: UIView {
    
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .fill
        $0.distribution = .fill
    }
    
    // MARK: - 컨테이너
    private let ownerWorkplaceContainerView = OwnerWorkplaceContainerView()
    private let colorLabelContainerView = ColorLabelContainerView()
    
    // MARK: - UI Components
    private let registerButton = BaseButton(title: "등록하기", isSecondary: true)
    
    // MARK: - Getter
    var getOwnerWorkplaceContainerView: OwnerWorkplaceContainerView { ownerWorkplaceContainerView }
    var getColorLabelContainerView: ColorLabelContainerView { colorLabelContainerView }
    var getRegisterButton: BaseButton { registerButton }

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}

private extension OwnerWorkplaceRegisterView {
    
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    func setHierarchy() {
        addSubviews(
            scrollView,
            registerButton
        )
        
        scrollView.addSubviews(contentView)
        contentView.addSubviews(stackView)
        
        stackView.addArrangedSubviews(
            ownerWorkplaceContainerView,
            colorLabelContainerView
        )
    }
    
    func setStyles() {
        backgroundColor = .white
    }
    
    func setConstraints() {
        
        // 버튼은 safeArea bottom 고정
        registerButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(45)
        }
        
        // 스크롤뷰는 버튼 위까지만
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(safeAreaLayoutGuide)
            $0.bottom.equalTo(registerButton.snp.top).offset(-12)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-24)
        }
    }
}
