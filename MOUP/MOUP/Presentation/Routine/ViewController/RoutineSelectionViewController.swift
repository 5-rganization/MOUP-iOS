//
//  RoutineSelectionViewController.swift
//  MOUP
//
//  Created by shinyoungkim on 9/14/25.
//

import UIKit
import RxSwift
import RxCocoa

final class RoutineSelectionViewController: UIViewController, UITableViewDelegate {
    
    typealias DataSource = UITableViewDiffableDataSource<Int, RoutineRowViewState>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, RoutineRowViewState>
    
    // MARK: - Properties
    
    weak var coordinator: RoutineSelectionCoordinator?
    private let routineSelectionView = RoutineSelectionView()
    private let viewModel: RoutineSelectionViewModel
    private let disposeBag = DisposeBag()
    
    private let addNewRoutineRelay = PublishRelay<Routine>()
    private let checkboxToggledRelay = PublishRelay<UUID>()
    private let routineUpdatedRelay = PublishRelay<Routine>()
    
    private lazy var dataSource = makeDataSource()
    
    private let latestRowsRelay = BehaviorRelay<[RoutineRowViewState]>(value: [])
    
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
        setStyles()
        setTableView()
        setDataSourceAndDelegate()
        setBindings()
    }
    
    // MARK: - setStyles
    func setStyles() {
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - setTableView
    func setTableView() {
        routineSelectionView.tableView.register(
            RoutineCell.self, forCellReuseIdentifier: RoutineCell.id
        )
    }
    
    // MARK: - setDataSourceAndDelegate
    func setDataSourceAndDelegate() {
        routineSelectionView.dataSource = self.dataSource
        routineSelectionView.delegate = self
    }
    
    // MARK: - setBindings
    func setBindings() {
        routineSelectionView.rx.plusButtonDidTap
            .bind(with: self) { owner, _ in
                owner.coordinator?.showAddRoutineViewController(onSave: { newRoutine in
                    owner.addNewRoutineRelay.accept(newRoutine)
                })
                
            }
            .disposed(by: disposeBag)
        
        let input = RoutineSelectionViewModel.Input(
            appear: self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
                .map { _ in () }
                .take(1),
            checkboxToggled: checkboxToggledRelay.asObservable(),
            addNewRoutine: addNewRoutineRelay.asObservable(),
            routineUpdated: routineUpdatedRelay.asObservable()
        )
        
        let output = viewModel.transform(input)
        
        output.rows
            .drive(onNext: { [weak self] rows in
                self?.latestRowsRelay.accept(rows)
                if let self,
                   self.isViewLoaded,
                   self.view.window != nil {
                    self.applySnapshot(with: rows, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        output.toggledRow
            .emit(onNext: { [weak self] toggledState in
                guard let self else { return }
                var currentSnapshot = self.dataSource.snapshot()
                currentSnapshot.reconfigureItems([toggledState])
                self.dataSource.apply(currentSnapshot, animatingDifferences: false)
            })
            .disposed(by: disposeBag)
        
        routineSelectionView.rx.itemSelected
            .compactMap { [weak self] indexPath in
                self?.dataSource.itemIdentifier(for: indexPath)
            }
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, viewState in
                owner.coordinator?.showEditRoutineViewController(routine: viewState.routine) { updated in
                    owner.routineUpdatedRelay.accept(updated)
                }
            }
            .disposed(by: disposeBag)
        
        routineSelectionView.rx.itemSelected
            .bind(to: routineSelectionView.rx.deselectRow)
            .disposed(by: disposeBag)
        
        self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .map { _ in () }
            .withLatestFrom(latestRowsRelay.asObservable())
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, rows in
                owner.applySnapshot(with: rows, animated: false)
            }
            .disposed(by: disposeBag)
    }
    
    func makeDataSource() -> DataSource {
        let dataSource = DataSource(tableView: routineSelectionView.tableView) { [weak self] tableView, indexPath, viewState in
            guard let self,
                  let cell = tableView.dequeueReusableCell(withIdentifier: RoutineCell.id, for: indexPath) as? RoutineCell else {
                return UITableViewCell()
            }
            
            cell.disposeBag = DisposeBag()
            cell.update(with: viewState)
            cell.rx.checkboxDidTap
                .map { viewState.routine.id }
                .bind(to: self.checkboxToggledRelay)
                .disposed(by: cell.disposeBag)
            
            return cell
        }
        return dataSource
    }
    
    func applySnapshot(with rows: [RoutineRowViewState], animated: Bool) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(rows, toSection: 0)
        snapshot.reloadItems(rows)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}
