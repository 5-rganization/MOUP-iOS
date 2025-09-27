//
//  RoutineEditorViewController.swift
//  MOUP
//
//  Created by 신영 on 9/27/25.
//

import UIKit
import RxSwift
import RxCocoa

final class RoutineEditorViewController: UIViewController {
    
    // MARK: - Properties
    
    private let rootView: RoutineEditorView
    private let viewModel: RoutineEditorViewModel
    private let disposeBag = DisposeBag()

    var onSaved: ((Routine) -> Void)?
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    
    // MARK: - Initializer
    
    init(
        mode: RoutineEditorViewModel.Mode,
        saveStratgy: SaveStrategy
    ) {
        let config = RoutineEditorConfig(
            mode: {
                switch mode {
                case .add: return .add
                case .edit: return .edit
                }
            }()
        )
        self.rootView = RoutineEditorView(config: config)
        self.viewModel = RoutineEditorViewModel(mode: mode, saveStrategy: saveStratgy)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension RoutineEditorViewController {
    // MARK: - Configure
    func configure() {
        setBindings()
    }
    
    // MARK: - setBindings
    func setBindings() {
        let selectedTime = rootView.rx.alarmTimeButtonTap
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
                    .take(1)
                    .do(onNext: { [weak timePickerVC] _ in
                        timePickerVC?.dismiss(animated: true)
                    }, onDispose: { [weak timePickerVC] in
                        if let vc = timePickerVC, vc.presentingViewController != nil {
                            vc.dismiss(animated: true)
                        }
                    })
            }
            .share()

        selectedTime
            .bind(with: self) { owner, comps in
                owner.viewModel.setAlarm(comps)
                owner.rootView.setAlarmTime(comps)
            }
            .disposed(by: disposeBag)

        let input = RoutineEditorViewModel.Input(
            viewDidLoad: Observable.just(()),
            titleChanged: rootView.rx.titleText.asObservable(),
            alarmTap: rootView.rx.alarmTimeButtonTap.asObservable(),
            addTodoTap: rootView.rx.addButtonTap.asObservable(),
            itemTextChanged: rootView.rx.itemTextChanged,
            itemMoved: rootView.rx.itemMoved,
            itemDeleted: rootView.rx.itemDeleted,
            saveTap: rootView.rx.saveButtonTap.asObservable(),
            backTap: rootView.rx.backButtonTap.asObservable()
        )

        let output = viewModel.transform(input)

        output.navTitle
            .drive(rootView.rx.navTitle)
            .disposed(by: disposeBag)

        output.rightButtonTitle
            .drive(rootView.rx.rightButtonTitle)
            .disposed(by: disposeBag)

        output.items
            .drive(rootView.rx.items)
            .disposed(by: disposeBag)

        output.focusOnRow
            .emit(to: rootView.rx.focusOnRow)
            .disposed(by: disposeBag)

        output.alarmComponents
            .drive(with: self) { owner, comp in owner.rootView.setAlarmTime(comp) }
            .disposed(by: disposeBag)

        output.title
            .map { Optional($0) }
            .drive(rootView.rx.titleText)
            .disposed(by: disposeBag)

        output.validationFocus
            .emit(with: self, onNext: { owner, target in
                switch target {
                case .title:
                    owner.rootView.focusOnTitle()
                case .alarmTime:
                    owner.rootView.shakeAlarmButton()
                case .firstTodoItem:
                    owner.rootView.rx.focusOnRow.onNext(0)
                }
            })
            .disposed(by: disposeBag)

        output.saveSucceeded
            .emit(with: self, onNext: { owner, routine in
                owner.onSaved?(routine)
            })
            .disposed(by: disposeBag)

        output.pop
            .emit(with: self, onNext: { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
