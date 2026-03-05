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
    private let restaurantRadioButton = OLDRadioButtonView(title: WorkplaceCategory.restaurant.displayStr,
                                                        type: .icon(selectedIcon: WorkplaceCategory.restaurant.selectedImage,
                                                                    unselectedIcon: WorkplaceCategory.restaurant.unselectedImage,
                                                                    selectedRadioButton: .selectedRadioButton,
                                                                    unselectedRadioButton: .unselectedRadioButton))
    
    private let cafeRadioButton = OLDRadioButtonView(title: WorkplaceCategory.cafe.displayStr,
                                                  type: .icon(selectedIcon: WorkplaceCategory.cafe.selectedImage,
                                                              unselectedIcon: WorkplaceCategory.cafe.unselectedImage,
                                                              selectedRadioButton: .selectedRadioButton,
                                                              unselectedRadioButton: .unselectedRadioButton))
    
    private let cvsRadioButton = OLDRadioButtonView(title: WorkplaceCategory.cvs.displayStr,
                                                 type: .icon(selectedIcon: WorkplaceCategory.cvs.selectedImage,
                                                             unselectedIcon: WorkplaceCategory.cvs.unselectedImage,
                                                             selectedRadioButton: .selectedRadioButton,
                                                             unselectedRadioButton: .unselectedRadioButton))
    
    private let movieTheaterRadioButton = OLDRadioButtonView(title: WorkplaceCategory.movieTheater.displayStr,
                                                          type: .icon(selectedIcon: WorkplaceCategory.movieTheater.selectedImage,
                                                                      unselectedIcon: WorkplaceCategory.movieTheater.unselectedImage,
                                                                      selectedRadioButton: .selectedRadioButton,
                                                                      unselectedRadioButton: .unselectedRadioButton))
    
    private let othersRadioButton = OLDRadioButtonView(title: WorkplaceCategory.others.displayStr,
                                                    type: .icon(selectedIcon: WorkplaceCategory.others.selectedImage,
                                                                unselectedIcon: WorkplaceCategory.others.unselectedImage,
                                                                selectedRadioButton: .selectedRadioButton,
                                                                unselectedRadioButton: .unselectedRadioButton))
    
    
    private let confirmButton = BaseButton(title: "완료").then {
        $0.isEnabled = false
    }
    
    // MARK: - Getter
    
    var getRestaurantRadioButton: OLDRadioButtonView { restaurantRadioButton }
    var getCafeRadioButton: OLDRadioButtonView { cafeRadioButton }
    var getCvsRadioButton: OLDRadioButtonView { cvsRadioButton }
    var getMovieTheaterRadioButton: OLDRadioButtonView { movieTheaterRadioButton }
    var getOthersRadioButton: OLDRadioButtonView { othersRadioButton }
    var getConfirmButton: BaseButton { confirmButton }
    
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
            movieTheaterRadioButton,
            othersRadioButton,
            confirmButton
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .primaryBackground
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
        
        movieTheaterRadioButton.snp.makeConstraints {
            $0.top.equalTo(cvsRadioButton.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        othersRadioButton.snp.makeConstraints {
            $0.top.equalTo(movieTheaterRadioButton.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        confirmButton.snp.makeConstraints {
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
