//
//  SelectedWorkplaceView.swift
//  MOUP
//
//  Created by 양원식 on 11/9/25.
//

import UIKit
import SnapKit
import Then
import RxRelay
import RxSwift
import RxCocoa

final class SelectedWorkplaceView: UIView {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    /// (근무지 id, 이름) 선택 결과를 외부로 전달
    let selectedWorkplace = PublishRelay<(id: Int, name: String)>()
    
    /// 현재 선택된 근무지 id
    private var currentSelectedId: Int?
    
    // MARK: - UI Components
    fileprivate let navigationBar = BaseNavigationBar(title: "근무지 선택")
    
    private let title = UILabel().then {
        $0.text = "등록할 근무지를 선택해 주세요"
        $0.textColor = .black
        $0.font = .headBold(16)
        $0.textAlignment = .left
    }
    
    private let radioStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .fill
        $0.distribution = .equalSpacing
    }
    
    private let registerButton = BaseButton(title: "완료", isSecondary: true)
    
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
}

// MARK: - Configure
private extension SelectedWorkplaceView {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setBindings()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            navigationBar,
            title,
            radioStackView,
            registerButton
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
        registerButton.isEnabled = false
        registerButton.update(title: "완료", isSecondary: true)
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalToSuperview()
        }
        
        title.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(32)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        radioStackView.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        registerButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(45)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(12)
        }
    }
    
    // MARK: - setBindings
    func setBindings() { }
}

// MARK: - Public Methods
extension SelectedWorkplaceView {
    func updateWorkplaceList(with workplaces: [WorkplaceSummary]) {
        // 기존 라디오 버튼 제거
        radioStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 새로운 라디오 버튼 추가
        for workplace in workplaces {
            let radioButton = RadioButtonView(
                title: workplace.name,
                type: .none(
                    selectedRadioButton: UIImage(named: "Check")!,
                    unselectedRadioButton: nil
                )
            )
            
            radioButton.setSelected(workplace.id == currentSelectedId)
            
            // 탭 이벤트 처리
            radioButton.rx.tap
                .subscribe(onNext: { [weak self] in
                    guard let self else { return }

                    // 현재 선택된 근무지 갱신
                    self.currentSelectedId = workplace.id

                    // 모든 버튼 상태 리셋 후 클릭된 버튼만 선택
                    self.radioStackView.arrangedSubviews
                        .compactMap { $0 as? RadioButtonView }
                        .forEach { $0.setSelected($0 === radioButton) }
                    
                    self.registerButton.isEnabled = true
                    self.registerButton.update(title: "완료", isSecondary: false)

                    // 선택된 근무지 정보 전달
                    self.selectedWorkplace.accept((id: workplace.id, name: workplace.name))
                })
                .disposed(by: disposeBag)
            
            radioStackView.addArrangedSubview(radioButton)
        }
    }
}

extension Reactive where Base: SelectedWorkplaceView {
    var navBackBtnTapped: ControlEvent<Void> {
        return base.navigationBar.rx.backBtnTapped
    }
}
