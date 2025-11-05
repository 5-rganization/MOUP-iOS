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
    var onSave: ((RoutineSummary) -> Void)?
    private let titleInputSubject = PublishSubject<String>()
    private let alarmTimeInputSubject = PublishSubject<DateComponents?>()
    private let itemsInputSubject = PublishSubject<[RoutineTaskItem]>()
    
    // MARK: - Lifecycle

    override func loadView() {
        self.view = addRoutineView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        checkAndPromptLoadDraft()
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
        
        let titleChanged = Observable.merge(
            addRoutineView.rx.titleText.orEmpty.asObservable(),
            titleInputSubject
        )
        
        let alarmTimeChanged = Observable.merge(
            selectedTime.map { Optional($0) }.asObservable(),
            alarmTimeInputSubject.asObservable()
        )
        
        let input = AddRoutineViewModel.Input(
            titleChanged: titleChanged,
            alarmTimeChanged: alarmTimeChanged,
            saveButtonTapped: addRoutineView.rx.saveButtonTap.asObservable(),
            addTodoButtonTapped: addRoutineView.rx.addButtonTap.asObservable(),
            itemTextChanged: addRoutineView.rx.itemTextChanged,
            itemMoved: addRoutineView.rx.itemMoved,
            itemDeleted: addRoutineView.rx.itemDeleted,
            itemsLoaded: itemsInputSubject.asObservable()
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
            .emit(with: self, onNext: { owner, routineSummary in
                owner.onSave?(routineSummary)
                owner.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        output.error
            .emit(with: self) { owner, message in
                print("에러: \(message)")
                
                let alert = NoticeModalViewController(
                    title: "루틴 생성 실패",
                    comment: message
                )
                
                owner.present(alert, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    func checkAndPromptLoadDraft() {
        guard let draft = DraftRoutineStorage.shared.loadDraft() else { return }

        let hasTitle = !draft.title.isEmpty
        let hasAlarmTime = draft.alarmTime != nil
        let hasValidItems = draft.items.contains { !$0.content.isEmpty }

        guard hasTitle || hasAlarmTime || hasValidItems else {
            DraftRoutineStorage.shared.deleteDraft()
            return
        }

        let alert = DeleteAlertViewController(
            alertTitle: "저장된 루틴이 있습니다",
            alertMessage: "이전에 저장한 내용을 불러올까요?",
            deleteButtonTitle: "불러오기"
        )

        alert.onDeleteConfirmed = { [weak self] in
            self?.loadDraft(draft)
        }

        alert.onCancelConfirmed = {
            DraftRoutineStorage.shared.deleteDraft()
        }

        present(alert, animated: false)
    }
    
    func loadDraft(_ draft: DraftRoutine) {
        if !draft.title.isEmpty {
            addRoutineView.updateRoutineTitleLabel(with: draft.title)
            titleInputSubject.onNext(draft.title)
        }
        
        if let alarmTime = draft.alarmTime {
            addRoutineView.updateAlarmTimeChip(with: alarmTime)
            alarmTimeInputSubject.onNext(alarmTime)
        }
        
        if !draft.items.isEmpty {
            let reindexedItems = draft.items.enumerated().map { index, item in
                RoutineTaskItem(content: item.content, orderIndex: index, id: item.id)
            }
            addRoutineView.restoreItems(reindexedItems)
            itemsInputSubject.onNext(reindexedItems)
        }
    }
}
