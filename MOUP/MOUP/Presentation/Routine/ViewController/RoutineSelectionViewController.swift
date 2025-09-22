//
//  RoutineSelectionViewController.swift
//  MOUP
//
//  Created by shinyoungkim on 9/14/25.
//

import UIKit
import RxSwift
import RxCocoa

final class RoutineSelectionViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: RoutineSelectionCoordinator?
    private let routineSelectionView = RoutineSelectionView()
    private let viewModel: RoutineSelectionViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = routineSelectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    // MARK: - Initializer
    
    init(viewModel: RoutineSelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }    
}

private extension RoutineSelectionViewController {
    // MARK: - configure
    func configure() {
        setBindings()
    }
    
    // MARK: - setBindings
    func setBindings() {
        routineSelectionView.rx.plusButtonDidTap
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.showAddRoutineViewController()
            })
            .disposed(by: disposeBag)
        
        let input = RoutineSelectionViewModel.Input(
            viewDidLoad: Observable.just(())
        )
        
        let output = viewModel.transform(input)
        
        routineSelectionView.rx
            .bindItems(output.rows.asObservable())
            .disposed(by: disposeBag)
    }
}
