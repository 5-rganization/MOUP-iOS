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
    private let viewModel = AddRoutineViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = addRoutineView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
}

private extension AddRoutineViewController {
    // MARK: - configure
    func configure() {
        setBindings()
    }
    
    // MARK: - setBindings
    func setBindings() {
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
    }
}
