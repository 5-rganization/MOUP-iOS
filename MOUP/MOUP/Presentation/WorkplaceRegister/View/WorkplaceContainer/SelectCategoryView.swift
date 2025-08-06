//
//  SelectCategoryView.swift
//  MOUP
//
//  Created by 양원식 on 7/24/25.
//
import UIKit
import SnapKit
import Then

final class SelectCategoryView: UIView {
    // MARK: - Properties
    
    // MARK: - UI Components
    private let title = UILabel().then {
        $0.text = "근무지 카테고리를 선택해주세요."
        $0.textColor = .gray900
        $0.font = .headBold(18)
    }
    private let restaurantRadioButton = RadioButtonView(title: "음식점", type: .icon(selectedIcon: UIImage(named:"RestaurantSelected")!, unselectedIcon: UIImage(named:"RestaurantUnselected")!, selectedRadioButton: UIImage(named:"selectedRadioButton")!, unselectedRadioButton: UIImage(named:"unselectedRadioButton")!))
    
    private let cafeRadioButton = RadioButtonView(title: "카페", type: .icon(selectedIcon: UIImage(named:"CafeSelected")!, unselectedIcon: UIImage(named:"CafeUnselected")!, selectedRadioButton: UIImage(named:"selectedRadioButton")!, unselectedRadioButton: UIImage(named:"unselectedRadioButton")!))
    
    private let cvsRadioButton = RadioButtonView(title: "편의점", type: .icon(selectedIcon: UIImage(named:"CVSSelected")!, unselectedIcon: UIImage(named:"CVSUnselected")!, selectedRadioButton: UIImage(named:"selectedRadioButton")!, unselectedRadioButton: UIImage(named:"unselectedRadioButton")!))
    
    private let theaterRadioButton = RadioButtonView(title: "영화관", type: .icon(selectedIcon: UIImage(named:"TheaterSelected")!, unselectedIcon: UIImage(named:"TheaterUnselected")!, selectedRadioButton: UIImage(named:"selectedRadioButton")!, unselectedRadioButton: UIImage(named:"unselectedRadioButton")!))
    
    private let etcRadioButton = RadioButtonView(title: "기타", type: .icon(selectedIcon: UIImage(named:"EtcSelected")!, unselectedIcon: UIImage(named:"EtcUnselected")!, selectedRadioButton: UIImage(named:"selectedRadioButton")!, unselectedRadioButton: UIImage(named:"unselectedRadioButton")!))
    
    
    private let registerButton = BaseButton(title: "완료", isSecondary: true)
    
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
        
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Public Methods
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
        title.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(32)
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

