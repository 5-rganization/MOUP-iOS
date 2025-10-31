//
//  WorkplaceRoutineListViewController.swift
//  MOUP
//
//  Created by 송규섭 on 10/6/25.
//

import UIKit
import RxSwift
import RxDataSources

class WorkplaceRoutineListViewController: UIViewController {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel: WorkplaceRoutineListViewModel
    private let workplaceRoutineListView: WorkplaceRoutineListView
    private let workId: Int
    private let dataSource = RxTableViewSectionedReloadDataSource<RoutineItem>(
        configureCell: { dataSource, tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RoutineListCell.identifier, for: indexPath) as? RoutineListCell else {
                return UITableViewCell()
            }
            cell.update(with: item)
            
            return cell
        })
    
    // MARK: - loadView
    override func loadView() {
        view = workplaceRoutineListView
    }
    
    // MARK: - Initializer
    init(viewModel: WorkplaceRoutineListViewModel, workplaceName: String, workId: Int) {
        self.viewModel = viewModel
        self.workplaceRoutineListView = WorkplaceRoutineListView(workplaceName: workplaceName)
        self.workId = workId
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

private extension WorkplaceRoutineListViewController {
    func configure() {
        setBindings()
    }
    
    func setBindings() {
        let input = WorkplaceRoutineListViewModel.Input(workId: Observable.just(workId))
        let output = viewModel.transform(input: input)
        
        workplaceRoutineListView.setupTableView(
            section: output.routineItem,
            dataSource: dataSource
        )
            .disposed(by: disposeBag)
        
        output.errorMessage
            .withUnretained(self)
            .subscribe(onNext: { owner, error in
                owner.presentNoticeModal(title: error.title, comment: error.message)
            })
            .disposed(by: disposeBag)
        
        workplaceRoutineListView.rx.navBackBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        Observable.zip(
            workplaceRoutineListView.rx.itemSelected,
            workplaceRoutineListView.rx.modelSelected
        )
        .withUnretained(self)
        .subscribe(onNext: { owner, result in
            print(result)
        })
        .disposed(by: disposeBag)
    }
}
