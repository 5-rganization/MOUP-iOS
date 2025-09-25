//
//  TimePickerSheetViewController.swift
//  MOUP
//
//  Created by 신영 on 9/25/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

final class TimePickerSheetViewController: UIViewController {
    
    // MARK: - Properties
    
    private let selectedTime = PublishRelay<DateComponents>()
    var selectedTimeEvent: Observable<DateComponents> { selectedTime.asObservable() }
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let container = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
        $0.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        $0.clipsToBounds = true
    }
    private let datePicker = UIDatePicker().then {
        $0.datePickerMode = .time
        $0.preferredDatePickerStyle = .wheels
        $0.locale = Locale(identifier: "en_GB")
    }
    fileprivate let cancelButton = BaseButton(title: "취소", isSecondary: true)
    fileprivate let doneButton = BaseButton(title: "선택")
    private let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.distribution = .fillEqually
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    
    func preset(_ comps: DateComponents?) {
        guard let comps,
              let date = Calendar(identifier: .gregorian).date(from: comps) else { return }
        datePicker.setDate(date, animated: false)
    }
}

private extension TimePickerSheetViewController {
    func configure() {
        setHierarchy()
        setConstraints()
        setActions()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        view.addSubview(container)
        
        container.addSubviews(
            datePicker,
            buttonStackView
        )
        
        buttonStackView.addArrangedSubviews(
            cancelButton,
            doneButton
        )
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        container.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        datePicker.snp.makeConstraints {
            $0.top.equalTo(container.safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.equalTo(container.safeAreaLayoutGuide)
            $0.bottom.equalTo(buttonStackView.snp.top).offset(-12)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.leading.trailing.equalTo(container.safeAreaLayoutGuide).inset(16)
            $0.bottom.equalTo(container.safeAreaLayoutGuide).inset(12)
            $0.height.equalTo(45)
        }
    }
    
    // MARK: - setActions
    func setActions() {
        cancelButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        doneButton.rx.tap
            .bind(with: self) { owner, _ in
                let comps = Calendar.current.dateComponents(
                    [.hour, .minute],
                    from: owner.datePicker.date
                )
                owner.selectedTime.accept(comps)
                owner.dismiss(animated: true, )
            }
            .disposed(by: disposeBag)
    }
}
