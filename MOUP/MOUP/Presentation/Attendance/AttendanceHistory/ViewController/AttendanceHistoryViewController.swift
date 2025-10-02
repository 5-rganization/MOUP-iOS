//
//  ManageAttendanceViewController.swift
//  MOUP
//
//  Created by 송규섭 on 9/24/25.
//

import UIKit
import RxSwift
import RxDataSources

class AttendanceHistoryViewController: UIViewController {
    // MARK: - Properties
    private let navTitle: String
    private lazy var attendanceHistoryView = AttendanceHistoryView(title: navTitle) // TODO: - 실제 쓰는 네임으로 변경 필요.
    private let viewModel: AttendanceHistoryViewModel
    private let disposeBag = DisposeBag()
    
    private let dataSource = RxTableViewSectionedReloadDataSource<AttendanceItem>(
        configureCell: { dataSource, tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AttendanceCell.identifier, for: indexPath) as? AttendanceCell else {
                return UITableViewCell()
            }
            cell.update(item: item)
            return cell
    })
    
    // MARK: - loadView
    override func loadView() {
        view = attendanceHistoryView
    }
    
    // MARK: - Initializer
    init(viewModel: AttendanceHistoryViewModel, navTitle: String) {
        self.navTitle = navTitle
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

private extension AttendanceHistoryViewController {
    // MARK: - configure
    func configure() {
        setStyles()
        setBindings()
    }
    
    // MARK: - setStyles
    func setStyles() {
        view.backgroundColor = .primaryBackground
        self.tabBarController?.tabBar.isHidden = true
    }
    
    // MARK: - setBindings
    func setBindings() {
        let input = AttendanceHistoryViewModel.Input(viewDidLoad: .just(()))
        let output = viewModel.transform(input: input)
        
        attendanceHistoryView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        attendanceHistoryView.setupTableView(section: output.attendanceData, dataSource: dataSource)
            .disposed(by: disposeBag)
        
        attendanceHistoryView.rx.navBackBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

extension AttendanceHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: AttendanceHistoryTableHeaderView.identifier) as? AttendanceHistoryTableHeaderView else {
            return UIView()
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 51 // 하단 셀들 간의 간격이 12, 첫 번째 셀의 상단 constant 12이므로 6 별도로 제공. 45 + 6
    }
}
