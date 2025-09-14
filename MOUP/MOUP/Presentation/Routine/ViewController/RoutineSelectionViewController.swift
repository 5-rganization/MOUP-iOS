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
    
    private let routineSelectionView = RoutineSelectionView()
    private let viewModel = RoutineSelectionViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = routineSelectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }

}

private extension RoutineSelectionViewController {
    // MARK: - configure
    func configure() {
        setBindings()
    }
    
    // MARK: - setBindings
    func setBindings() {
        let input = RoutineSelectionViewModel.Input(
            viewDidLoad: Observable.just(())
        )
        
        let output = viewModel.transform(input)
        
        routineSelectionView.rx
            .bindItems(output.rows.asObservable())
            .disposed(by: disposeBag)
    }
}
