//
//  TodayRoutineViewController.swift
//  MOUP
//
//  Created by 송규섭 on 10/5/25.
//

import UIKit
import RxSwift
import RxRelay
import RxDataSources

class TodayRoutineViewController: UIViewController {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel: TodayRoutineViewModel
    private let todayRoutineView = TodayRoutineView()
    
    private let dataSources = RxTableViewSectionedReloadDataSource<TodayRoutineItem>(
        configureCell: { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: TodayRoutineCell.identifier, for: indexPath)
            
            return cell
        })
    
    // MARK: - loadView
    override func loadView() {
        view = todayRoutineView
    }
    
    // MARK: - Initializer
    init(viewModel: TodayRoutineViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
}

private extension TodayRoutineViewController {
    func configure() {
        setBindings()
    }
    
    func setBindings() {
        let input = TodayRoutineViewModel.Input(viewDidLoad: .just(()))
        let output = viewModel.transform(input: input)
        
        todayRoutineView.setupTableView(
            section: output.todayRoutine,
            dataSource: dataSources
        )
        .disposed(by: disposeBag)
    }
}
