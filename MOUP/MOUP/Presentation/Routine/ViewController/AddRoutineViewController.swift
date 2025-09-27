//
//  AddRoutineViewController.swift
//  MOUP
//
//  Created by shinyoungkim on 9/16/25.
//

import UIKit
import RxSwift
import RxCocoa

final class AddRoutineViewController: UIViewController {
    
    // MARK: - Properties
    
    private let addRoutineView = AddRoutineView()
    private let viewModel: AddRoutineViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = addRoutineView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    
    // MARK: - Initializer
    
    init(viewModel: AddRoutineViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension AddRoutineViewController {
    // MARK: - configure
    func configure() {
        setBindings()
    }
    
    // MARK: - setBindings
    func setBindings() {
        addRoutineView.rx.backButtonTap
            .bind(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        let selectedTime = addRoutineView.rx.alarmTimeButtonTap
            .flatMapLatest { [weak self] _ -> Observable<DateComponents> in
                guard let self else { return .empty() }
                
                let timePickerVC = TimePickerSheetViewController()
                
                if let sheet = timePickerVC.sheetPresentationController {
                    sheet.detents = [.medium()]
                    sheet.prefersGrabberVisible = true
                    sheet.prefersScrollingExpandsWhenScrolledToEdge = true
                    sheet.preferredCornerRadius = 16
                }
                
                self.present(timePickerVC, animated: true)
                
                return timePickerVC.selectedTimeEvent
            }
            .share()
        
        selectedTime
            .bind(with: self) { owner, comps in
                owner.addRoutineView.updateAlarmTimeChip(with: comps)
            }
            .disposed(by: disposeBag)
        
        let input = AddRoutineViewModel.Input(
            titleChanged: addRoutineView.rx.titleText.orEmpty.asObservable(),
            alarmTimeChanged: selectedTime.map { Optional($0) }.asObservable(),
            saveButtonTapped: addRoutineView.rx.saveButtonTap.asObservable(),
            addTodoButtonTapped: addRoutineView.rx.addButtonTap.asObservable(),
            itemTextChanged: addRoutineView.rx.itemTextChanged,
            itemMoved: addRoutineView.rx.itemMoved,
            itemDeleted: addRoutineView.rx.itemDeleted
        )
        
        let output = viewModel.transform(input: input)
        
        output.items
            .drive(addRoutineView.rx.items)
            .disposed(by: disposeBag)
        
        output.focusOnRow
            .emit(to: addRoutineView.rx.focusOnRow)
            .disposed(by: disposeBag)
        
        output.title
            .drive(addRoutineView.rx.titleText)
            .disposed(by: disposeBag)
        
        output.validationFocus
            .emit(with: self, onNext: { owner, target in
                switch target {
                case .title:
                    owner.addRoutineView.focusOnTitle()
                case .alarmTime:
                    owner.addRoutineView.shakeAlarmButton()
                case .firstTodoItem:
                    let focusBinder = owner.addRoutineView.rx.focusOnRow
                    focusBinder.onNext(0)
                }
            })
            .disposed(by: disposeBag)
        
        output.saveCompleted
            .emit(with: self, onNext: { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
