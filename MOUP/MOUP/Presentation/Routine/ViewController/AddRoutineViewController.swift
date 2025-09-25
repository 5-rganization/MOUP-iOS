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
        
        addRoutineView.rx.alarmTimeButtonTap
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
            .bind(with: self) { owner, comps in
                let hour = comps.hour ?? 0
                let minute = comps.minute ?? 0
                print("선택한 시간: \(hour)시 \(minute)분")

            }
            .disposed(by: disposeBag)
        
        let input = AddRoutineViewModel.Input(
            titleChanged: addRoutineView.rx.titleText.orEmpty.asObservable(),
            addTodoButtonTapped: addRoutineView.rx.addButtonTap.asObservable(),
            itemTextChanged: addRoutineView.rx.itemTextChanged,
            itemMoved: addRoutineView.rx.itemMoved
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
    }
}
