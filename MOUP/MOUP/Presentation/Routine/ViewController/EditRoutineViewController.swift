//
//  AddRoutineViewController.swift
//  MOUP
//
//  Created by shinyoungkim on 9/16/25.
//

import UIKit
import RxSwift
import RxCocoa

final class EditRoutineViewController: UIViewController {
    
    // MARK: - Properties
    
    private let editRoutinedView = EditRoutineView()
    private let viewModel: EditRoutineViewModel
    private let disposeBag = DisposeBag()
    var onEdit: ((Routine) -> Void)?
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = editRoutinedView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    
    // MARK: - Initializer
    
    init(viewModel: EditRoutineViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension EditRoutineViewController {
    // MARK: - configure
    func configure() {
        setBindings()
    }
    
    // MARK: - setBindings
    func setBindings() {
        editRoutinedView.rx.backButtonTap
            .bind(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        let selectedTime = editRoutinedView.rx.alarmTimeButtonTap
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
                owner.editRoutinedView.updateAlarmTimeChip(with: comps)
            }
            .disposed(by: disposeBag)
        
        let input = EditRoutineViewModel.Input(
            titleChanged: editRoutinedView.rx.titleText
                .orEmpty
                .skip(1)
                .distinctUntilChanged(),
            alarmTimeChanged: selectedTime.map { Optional($0) }.asObservable(),
            editButtonTapped: editRoutinedView.rx.editButtonTap.asObservable(),
            addTodoButtonTapped: editRoutinedView.rx.addButtonTap.asObservable(),
            itemTextChanged: editRoutinedView.rx.itemTextChanged,
            itemMoved: editRoutinedView.rx.itemMoved,
            itemDeleted: editRoutinedView.rx.itemDeleted
        )
        
        let output = viewModel.transform(input: input)
        
        output.items
            .drive(editRoutinedView.rx.items)
            .disposed(by: disposeBag)
        
        output.focusOnRow
            .emit(to: editRoutinedView.rx.focusOnRow)
            .disposed(by: disposeBag)
        
        output.title
            .drive(editRoutinedView.rx.titleText)
            .disposed(by: disposeBag)
        
        output.alarmTime
            .drive(with: self) { owner, comps in
                if let comps {
                    owner.editRoutinedView.updateAlarmTimeChip(with: comps)
                }
            }
            .disposed(by: disposeBag)
        
        output.validationFocus
            .emit(with: self, onNext: { owner, target in
                switch target {
                case .title:
                    owner.editRoutinedView.focusOnTitle()
                case .alarmTime:
                    owner.editRoutinedView.shakeAlarmButton()
                case .firstTodoItem:
                    let focusBinder = owner.editRoutinedView.rx.focusOnRow
                    focusBinder.onNext(0)
                }
            })
            .disposed(by: disposeBag)
        
        output.editCompleted
            .emit(with: self, onNext: { owner, newRoutine in
                owner.onEdit?(newRoutine)
                owner.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
