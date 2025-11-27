//
//  ManageAttendanceViewController.swift
//  MOUP
//
//  Created by 송규섭 on 9/26/25.
//

import UIKit
import RxSwift
import RxDataSources

final class ManageAttendanceViewController: UIViewController {
    // MARK: - Properties
    private let manageAttendanceView = ManageAttendanceView()
    private let viewModel: ManageAttendanceViewModel
    private let disposeBag = DisposeBag()
    weak var coordinator: HomeCoordinator?
    
    private let dataSource = RxTableViewSectionedReloadDataSource<ManageAttendanceItem>(
        configureCell: { dataSource, tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ManageAttendanceCell.identifier, for: indexPath) as? ManageAttendanceCell else {
                return UITableViewCell()
            }
            let color = LabelColor(serverStr: item.workerBasedLabelColorStr ?? LabelColor._default.serverStr) ?? ._default
            cell.update(color: color.labelColor, name: item.nickname)
            return cell
    })
    
    // MARK: - loadView
    override func loadView() {
        view = manageAttendanceView
    }
    
    // MARK: - Initializer
    init(
        viewModel: ManageAttendanceViewModel,
        coordinator: HomeCoordinator
    ) {
        self.viewModel = viewModel
        self.coordinator = coordinator
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

private extension ManageAttendanceViewController {
    // MARK: - configure
    func configure() {
        setStyles()
        setBindings()
    }
    
    // MARK: - setStyles
    func setStyles() {
        view.backgroundColor = .primaryBackground
    }
    
    // MARK: - setBindings
    func setBindings() {
        let input = ManageAttendanceViewModel.Input(viewDidLoad: .just(()))
        let output = viewModel.transform(input: input)
        
        let sharedWorkers = output.workers.share()
        
        manageAttendanceView.setupTableView(section: sharedWorkers, dataSource: dataSource)
            .disposed(by: disposeBag)
        
        sharedWorkers
            .map { $0.first?.items.isEmpty ?? true }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, isEmpty in
                owner.manageAttendanceView.updateEmptyState(isEmpty)
            }
            .disposed(by: disposeBag)
        
        manageAttendanceView.rx.navBackBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        manageAttendanceView.rx.modelSelected
            .subscribe(onNext: { [weak self] model in
                guard let self else { return }
                self.coordinator?.moveToAttendanceHistory(
                    workplaceId: self.viewModel.workplaceId,
                    workerId: model.id,
                    navTitle: model.nickname
                )
            })
            .disposed(by: disposeBag)
        
        manageAttendanceView.rx.inviteBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.coordinator?.presentInviteCodeSheet(workplaceId: owner.viewModel.workplaceId)
            })
            .disposed(by: disposeBag)
        
        output.errorMessage
            .withUnretained(self)
            .subscribe(
                onNext: { owner, error in
                    owner.presentNoticeModal(
                        title: error.title,
                        comment: error.message) {
                            owner.navigationController?.popViewController(animated: true)
                        }
            })
            .disposed(by: disposeBag)
    }
}
