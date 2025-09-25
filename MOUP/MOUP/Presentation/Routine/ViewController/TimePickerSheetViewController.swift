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
    private var containerBottomConstraint: Constraint?
    private var panStartOffset: CGFloat = 0
    private let panDismissThreshold: CGFloat = 120
    private let panMaxOffset: CGFloat = 300
    
    // MARK: - UI Components
    
    private let grabberView = ModalGrabberView()
    private let dragAreaView = UIView()
    private let container = UIView()
    private let dimView = UIControl().then {
        $0.backgroundColor = .modalBackground
    }
    private let datePicker = UIDatePicker().then {
        $0.datePickerMode = .time
        $0.preferredDatePickerStyle = .wheels
        $0.locale = Locale(identifier: "en_GB")
        $0.minuteInterval = 1
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        containerBottomConstraint?.update(offset: 0)
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func dismissWithSlideOut() {
        containerBottomConstraint?.update(offset: 300)
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            self?.dismiss(animated: false)
        })
    }
    
    func preset(_ comps: DateComponents?) {
        var dc = DateComponents()
        dc.hour = comps?.hour
        dc.minute = comps?.minute
        let cal = Calendar(identifier: .gregorian)
        if let date = cal.date(from: dc) {
            datePicker.setDate(date, animated: false)
        }
    }
}

private extension TimePickerSheetViewController {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        view.addSubviews(
            dimView,
            container
        )
        
        container.addSubviews(
            dragAreaView,
            datePicker,
            buttonStackView
        )
        
        dragAreaView.addSubview(grabberView)
        
        buttonStackView.addArrangedSubviews(
            cancelButton,
            doneButton
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        view.backgroundColor = .clear
        
        container.do {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 16
            $0.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner
            ]
            $0.clipsToBounds = true
        }
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        dimView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        container.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            containerBottomConstraint = $0.bottom.equalToSuperview()
                .offset(300)
                .constraint
        }
        
        dragAreaView.snp.makeConstraints {
            $0.top.equalTo(container)
            $0.leading.trailing.equalTo(container)
            $0.height.equalTo(28)
        }
        
        grabberView.snp.makeConstraints {
            $0.centerX.equalTo(dragAreaView)
            $0.centerY.equalTo(dragAreaView)
            $0.width.equalTo(45)
            $0.height.equalTo(4)
        }
        
        datePicker.snp.makeConstraints {
            $0.top.equalTo(dragAreaView.snp.bottom)
            $0.leading.trailing.equalTo(container)
            $0.bottom.equalTo(buttonStackView.snp.top).offset(-12)
            $0.height.greaterThanOrEqualTo(216)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.leading.trailing.equalTo(container).inset(16)
            $0.bottom.equalTo(container.safeAreaLayoutGuide).inset(12)
            $0.height.equalTo(45)
        }
        
        container.snp.makeConstraints {
            $0.height.lessThanOrEqualTo(view.snp.height)
                .multipliedBy(0.6).priority(999)
        }
    }
    
    // MARK: - setActions
    func setActions() {
        dimView.rx.controlEvent(.touchUpInside)
            .bind(with: self) { owner, _ in owner.dismissWithSlideOut() }
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .bind(with: self) { owner, _ in owner.dismissWithSlideOut() }
            .disposed(by: disposeBag)
        
        doneButton.rx.tap
            .bind(with: self) { owner, _ in
                let comps = Calendar.current.dateComponents(
                    [.hour, .minute],
                    from: owner.datePicker.date
                )
                owner.selectedTime.accept(comps)
                owner.dismissWithSlideOut()
            }
            .disposed(by: disposeBag)
        
        let pan = UIPanGestureRecognizer(
            target: self,
            action: #selector(handleGrabberPan(_:))
        )
        dragAreaView.addGestureRecognizer(pan)
        dragAreaView.isUserInteractionEnabled = true
    }
    
    @objc func handleGrabberPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        switch gesture.state {
        case .began:
            panStartOffset = containerBottomConstraint?.layoutConstraints.first?.constant ?? 0
        case .changed:
            let raw = panStartOffset + translation.y
            let clamped = min(max(raw, 0), panMaxOffset)
            containerBottomConstraint?.update(offset: clamped)
            view.layoutIfNeeded()
        case .ended, .cancelled, .failed:
            let velocityY = gesture.velocity(in: view).y
            let currentOffset = containerBottomConstraint?.layoutConstraints.first?.constant ?? 0
            let shouldDismiss = (currentOffset > panDismissThreshold) || (velocityY > 1000)
            if shouldDismiss {
                dismissWithSlideOut()
            } else {
                containerBottomConstraint?.update(offset: 0)
                UIView.animate(withDuration: 0.2) { self.view.layoutIfNeeded() }
            }
        default:
            break
        }
    }
}
