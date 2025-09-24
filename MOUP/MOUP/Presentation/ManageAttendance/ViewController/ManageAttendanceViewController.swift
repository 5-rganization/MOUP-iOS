//
//  ManageAttendanceViewController.swift
//  MOUP
//
//  Created by 송규섭 on 9/24/25.
//

import UIKit
import RxSwift

class ManageAttendanceViewController: UIViewController {
    // MARK: - Properties
    private let manageAttendanceView = ManageAttendanceView(title: "맥도날드 수유점") // TODO: - 실제 쓰는 네임으로 변경 필요.
    private let viewModel: ManageAttendanceViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - loadView
    override func loadView() {
        view = manageAttendanceView
    }
    
    // MARK: - Initializer
    init(viewModel: ManageAttendanceViewModel) {
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

private extension ManageAttendanceViewController {
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
        manageAttendanceView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
}

extension ManageAttendanceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ManageAttendanceTableHeaderView.identifier) as? ManageAttendanceTableHeaderView else {
            return UIView()
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 51 // 하단 셀들 간의 간격이 12, 첫 번째 셀의 상단 constant 12이므로 6 별도로 제공. 60 + 6
    }
}
