//
//  SelectCategoryView.swift
//  MOUP
//
//  Created by 양원식 on 7/24/25.
//
import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

final class SelectCategoryView: UIView {
    // MARK: - Properties
    
    // MARK: - UI Components
    fileprivate let navigationBar = BaseNavigationBar(title: "카테고리")
    
    private let title = UILabel().then {
        $0.text = "근무지 카테고리를 선택해주세요."
        $0.textColor = .gray900
        $0.font = .headBold(18)
    }
    private let restaurantRadioButton = RadioButtonView(title: "음식점", type: .icon(selectedIcon: .restaurantSelected, unselectedIcon: .restaurantUnselected, selectedRadioButton: .selectedRadioButton, unselectedRadioButton: .unselectedRadioButton))
    
    private let cafeRadioButton = RadioButtonView(title: "카페", type: .icon(selectedIcon: .cafeSelected, unselectedIcon: .cafeUnselected, selectedRadioButton: .selectedRadioButton, unselectedRadioButton: .unselectedRadioButton))
    
    private let cvsRadioButton = RadioButtonView(title: "편의점", type: .icon(selectedIcon: .cvsSelected, unselectedIcon: .cvsUnselected, selectedRadioButton: .selectedRadioButton, unselectedRadioButton: .unselectedRadioButton))
    
    private let theaterRadioButton = RadioButtonView(title: "영화관", type: .icon(selectedIcon: .theaterSelected, unselectedIcon: .theaterUnselected, selectedRadioButton: .selectedRadioButton, unselectedRadioButton: .unselectedRadioButton))
    
    private let etcRadioButton = RadioButtonView(title: "기타", type: .icon(selectedIcon: .etcSelected, unselectedIcon: .etcUnselected, selectedRadioButton: .selectedRadioButton, unselectedRadioButton: .unselectedRadioButton))
    
    
    private let registerButton = BaseButton(title: "완료").then {
        $0.isEnabled = false
    }
    
    // MARK: - Getter
    
    var getRestaurantRadioButton: RadioButtonView { restaurantRadioButton }
    var getCafeRadioButton: RadioButtonView { cafeRadioButton }
    var getCvsRadioButton: RadioButtonView { cvsRadioButton }
    var getTheaterRadioButton: RadioButtonView { theaterRadioButton }
    var getEtcRadioButton: RadioButtonView { etcRadioButton }
    var getRegisterButton: BaseButton { registerButton }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupRoleTitle()
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Public Methods
    func setupRoleTitle() {
        let role = UserDefaultsManager.shared.userRole
        
        if role == "OWNER" {
            title.text = "매장 카테고리를 선택해주세요."
        } else {
            title.text = "근무지 카테고리를 선택해주세요."
        }
    }
}

private extension SelectCategoryView {
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
            title,
            restaurantRadioButton,
            cafeRadioButton,
            cvsRadioButton,
            theaterRadioButton,
            etcRadioButton,
            registerButton
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
            $0.directionalHorizontalEdges.equalTo(safeAreaLayoutGuide)
        }
        
        title.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(16)
        }
        restaurantRadioButton.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        cafeRadioButton.snp.makeConstraints {
            $0.top.equalTo(restaurantRadioButton.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        cvsRadioButton.snp.makeConstraints {
            $0.top.equalTo(cafeRadioButton.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        theaterRadioButton.snp.makeConstraints {
            $0.top.equalTo(cvsRadioButton.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        etcRadioButton.snp.makeConstraints {
            $0.top.equalTo(theaterRadioButton.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        registerButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(45)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(12)
        }
    }
}

extension Reactive where Base: SelectCategoryView {
    var navBackBtnTapped: ControlEvent<Void> {
        return base.navigationBar.rx.backBtnTapped
    }
}
