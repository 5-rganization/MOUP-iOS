//
//  ManageAttendanceViewController.swift
//  MOUP
//
//  Created by 송규섭 on 9/26/25.
//

import UIKit
import RxSwift
import RxDataSources

class ManageAttendanceViewController: UIViewController {
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
            let color = LabelColorString.init(rawValue: item.labelColor)?.labelColor ?? .primary50
            cell.update(color: color, name: item.name)
            return cell
    })
    
    // MARK: - loadView
    override func loadView() {
        view = manageAttendanceView
    }
    
    // MARK: - Initializer
    init(viewModel: ManageAttendanceViewModel, coordinator: HomeCoordinator) {
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
        
        manageAttendanceView.setupTableView(section: output.employees, dataSource: dataSource)
            .disposed(by: disposeBag)
        
        manageAttendanceView.rx.navBackBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        manageAttendanceView.rx.modelSelected
            .withUnretained(self)
            .subscribe(onNext: { owner, model in
                owner.coordinator?.moveToAttendanceHistory(navTitle: model.name)
            })
            .disposed(by: disposeBag)
    }
}
