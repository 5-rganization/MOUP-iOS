//
//  HomeViewController.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import UIKit
import RxSwift
import RxDataSources

final class HomeViewController: UIViewController {
    // MARK: - Properties
    weak var coordinator: HomeCoordinator?
    private let homeViewModel: HomeViewModel
    private let homeView = HomeView()
    private let disposeBag = DisposeBag()

    private lazy var dataSource = RxTableViewSectionedAnimatedDataSource<HomeTableViewFirstSection>(animationConfiguration: AnimationConfiguration(deleteAnimation: .automatic)) { dataSource, tableView, indexPath, item in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WorkerWorkplaceCell.identifier, for: indexPath) as? WorkerWorkplaceCell else {
            return UITableViewCell()
        }
        cell.update(item: item)
        return cell
    }


    // MARK: - loadView
    override func loadView() {
        view = homeView
    }

    // MARK: - Initializer
    init(coordinator: HomeCoordinator? = nil, homeViewModel: HomeViewModel) {
        self.coordinator = coordinator
        self.homeViewModel = homeViewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

}

private extension HomeViewController {
    func configure() {
        setStyles()
        setBindings()
    }

    func setStyles() {
        self.navigationController?.navigationBar.isHidden = true
    }

    func setBindings() {
        let input = HomeViewModel.Input(viewDidLoad: Observable.just(()))
        let output = homeViewModel.transform(input: input)

        homeView.rx.todayRoutineCardTap.subscribe(onNext: {
            print("오늘의 루틴 탭")
        })
        .disposed(by: disposeBag)

        homeView.rx.allRoutineCardTap.subscribe(onNext: {
            print("모든 루틴 탭")
        })
        .disposed(by: disposeBag)

        homeView.rx.plusButtonTap.subscribe(onNext: {
            print("플러스 버튼 탭")
        })
        .disposed(by: disposeBag)

        homeView.setupTableView(section: output.firstSectionData, dataSource: dataSource)
            .disposed(by: disposeBag)
    }
}
