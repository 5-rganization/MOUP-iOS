//
//  AllRoutineViewController.swift
//  MOUP
//
//  Created by 송규섭 on 10/5/25.
//

import UIKit
import RxSwift
import RxRelay
import RxDataSources

final class AllRoutineViewController: UIViewController {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel: AllRoutineViewModel
    private let allRoutineView = AllRoutineView()
    
    private let dataSources = RxTableViewSectionedReloadDataSource<RoutineItem>(
        configureCell: { dataSource, tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AllRoutineCell.identifier, for: indexPath) as? AllRoutineCell else {
                return UITableViewCell()
            }
            cell.update(with: item)
            
            return cell
        })
    
    // MARK: - loadView
    override func loadView() {
        view = allRoutineView
    }
    
    // MARK: - Initializer
    init(viewModel: AllRoutineViewModel) {
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

private extension AllRoutineViewController {
    // MARK: - configure
    func configure() {
        setBindings()
    }
    
    func setBindings() {
        let input = AllRoutineViewModel.Input(viewDidLoad: .just(()))
        let output = viewModel.transform(input: input)
        
        allRoutineView.setupTableView(section: output.allRoutines, dataSource: dataSources)
            .disposed(by: disposeBag)
        
        allRoutineView.rx.navBackBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
