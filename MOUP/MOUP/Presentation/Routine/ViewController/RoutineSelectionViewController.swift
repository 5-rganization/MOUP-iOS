//
//  RoutineSelectionViewController.swift
//  MOUP
//
//  Created by shinyoungkim on 9/14/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class RoutineSelectionViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: RoutineSelectionCoordinator?
    private let routineSelectionView = RoutineSelectionView()
    private let viewModel: RoutineSelectionViewModel
    private let disposeBag = DisposeBag()
    
    private let addNewRoutineRelay = PublishRelay<RoutineSummary>()
    private let checkboxToggledRelay = PublishRelay<Int>()
    private let routineUpdatedRelay = PublishRelay<RoutineSummary>()
    
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
    
    // MARK: - setBindings
    func setBindings() {
        let dataSource = createDataSource()
        
        routineSelectionView.rx.backButtonDidTap
            .bind(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
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
            .drive(routineSelectionView.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.error
            .emit(with: self) { owner, message in
                print("❌ 에러: \(message)")
                // TODO: - 에러 알림 표시
            }
            .disposed(by: disposeBag)
        
        routineSelectionView.tableView.rx.modelSelected(RoutineRowViewState.self)
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, viewState in
                // TODO: RoutineSummary → Routine 변환 후 수정 화면 이동
                print("⚠️ 루틴 수정 화면 이동 - ID: \(viewState.routine.routineId)")
                
//                owner.coordinator?.showEditRoutineViewController(
//                    routine: viewState.routine
//                ) { updated in
//                    owner.routineUpdatedRelay.accept(updated)
//                }
            }
            .disposed(by: disposeBag)
        
        routineSelectionView.rx.itemSelected
            .bind(to: routineSelectionView.rx.deselectRow)
            .disposed(by: disposeBag)
    }
    
    func createDataSource() -> RxTableViewSectionedAnimatedDataSource<RoutineSectionModel> {
        return RxTableViewSectionedAnimatedDataSource<RoutineSectionModel>(
            configureCell: { [weak self] dataSource, tableView, indexPath, viewState in
                guard let self else { return UITableViewCell() }
                guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: RoutineCell.id,
                        for: indexPath
                      ) as? RoutineCell else {
                    assertionFailure("RoutineCell dequeue 실패")
                    return UITableViewCell()
                }
                
                cell.update(with: viewState)
                
                cell.rx.checkboxDidTap
                    .map { viewState.routine.routineId }
                    .bind(to: self.checkboxToggledRelay)
                    .disposed(by: cell.disposeBag)
                
                return cell
            }
        )
    }
}
