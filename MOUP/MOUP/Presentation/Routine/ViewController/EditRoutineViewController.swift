//
//  AddRoutineViewController.swift
//  MOUP
//
//  Created by shinyoungkim on 9/16/25.
//

import OSLog

import UIKit
import RxSwift
import RxCocoa

final class EditRoutineViewController: UIViewController {

    // MARK: - Properties

    private let editRoutineView = EditRoutineView()
    private let viewModel: EditRoutineViewModel
    private let disposeBag = DisposeBag()
    var onEdit: ((RoutineSummary) -> Void)?
    private let viewDidLoadSubject = PublishSubject<Void>()
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "EditRoutineViewController"
    )
    
    // MARK: - Lifecycle

    override func loadView() {
        self.view = editRoutineView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        viewDidLoadSubject.onNext(())
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
        editRoutineView.rx.backButtonTap
            .bind(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)

        let selectedTime = editRoutineView.rx.alarmTimeButtonTap
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
                owner.editRoutineView.updateAlarmTimeChip(with: comps)
            }
            .disposed(by: disposeBag)

        let input = EditRoutineViewModel.Input(
            viewDidLoad: viewDidLoadSubject.asObservable(),
            titleChanged: editRoutineView.rx.titleText
                .orEmpty
                .skip(1)
                .distinctUntilChanged(),
            alarmTimeChanged: selectedTime.map { Optional($0) }.asObservable(),
            editButtonTapped: editRoutineView.rx.editButtonTap.asObservable(),
            addTodoButtonTapped: editRoutineView.rx.addButtonTap.asObservable(),
            itemTextChanged: editRoutineView.rx.itemTextChanged,
            itemMoved: editRoutineView.rx.itemMoved,
            itemDeleted: editRoutineView.rx.itemDeleted
        )

        let output = viewModel.transform(input: input)

        output.items
            .drive(editRoutineView.rx.items)
            .disposed(by: disposeBag)

        output.focusOnRow
            .emit(to: editRoutineView.rx.focusOnRow)
            .disposed(by: disposeBag)

        output.title
            .drive(editRoutineView.rx.titleText)
            .disposed(by: disposeBag)

        output.alarmTime
            .drive(with: self) { owner, comps in
                if let comps {
                    owner.editRoutineView.updateAlarmTimeChip(with: comps)
                }
            }
            .disposed(by: disposeBag)

        output.validationFocus
            .emit(with: self, onNext: { owner, target in
                switch target {
                case .title:
                    owner.editRoutineView.focusOnTitle()
                case .alarmTime:
                    owner.editRoutineView.shakeAlarmButton()
                case .firstTodoItem:
                    let focusBinder = owner.editRoutineView.rx.focusOnRow
                    focusBinder.onNext(0)
                }
            })
            .disposed(by: disposeBag)

        output.editCompleted
            .emit(with: self, onNext: { owner, updated in
                owner.onEdit?(updated)
                owner.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        output.error
            .emit(with: self) { owner, message in
                print("에러: \(message)")

                let alert = NoticeModalViewController(
                    title: "루틴 수정 실패",
                    comment: message
                )
                alert.modalTransitionStyle = .crossDissolve
                alert.modalPresentationStyle = .overFullScreen

                owner.present(alert, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.isLoading
            .drive(with: self) { owner, isLoading in
                if isLoading {
                    // TODO: - 로딩 인디케이터 표시
                } else {
                    // TODO: - 로딩 인디케이터 숨김
                }
            }
            .disposed(by: disposeBag)
        
        output.fetchError
            .emit(with: self) { owner, message in
                owner.logger.error("Fetch 에러: \(message)")
                
                let alert = NoticeModalViewController(
                    title: "오류",
                    comment: message
                )
                alert.modalTransitionStyle = .crossDissolve
                alert.modalPresentationStyle = .overFullScreen
                
                owner.present(alert, animated: true) {
                    owner.navigationController?.popViewController(animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
}
