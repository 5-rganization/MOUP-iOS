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
    private let homeView: HomeView
    private let userRole: UserRole
    private let disposeBag = DisposeBag()
    
    private lazy var dataSource = RxTableViewSectionedAnimatedDataSource<HomeTableViewFirstSection>(animationConfiguration: AnimationConfiguration(deleteAnimation: .automatic)) { dataSource, tableView, indexPath, item in
        switch item {
        case .owner:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OwnerWorkplaceCell.identifier, for: indexPath) as? OwnerWorkplaceCell else {
                return UITableViewCell()
            }
            let menu = self.setMenu(role: .owner)
            cell.update(item: item, menu: menu)
            cell.delegate = self
            return cell
        case .worker:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: WorkerWorkplaceCell.identifier, for: indexPath) as? WorkerWorkplaceCell else {
                return UITableViewCell()
            }
            let menu = self.setMenu(role: .worker)
            cell.update(item: item, menu: menu)
            cell.delegate = self
            return cell
        }
    }
    
    
    // MARK: - loadView
    override func loadView() {
        view = homeView
    }
    
    // MARK: - Initializer
    init(coordinator: HomeCoordinator? = nil, homeViewModel: HomeViewModel, userRole: UserRole) {
        self.coordinator = coordinator
        self.homeViewModel = homeViewModel
        self.userRole = userRole
        self.homeView = HomeView(userRole: userRole)
        
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
        
        homeView.rx.todayRoutineCardTap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                print("오늘의 루틴 탭")
                owner.coordinator?.moveToTodayRoutine()
            })
            .disposed(by: disposeBag)
        
        homeView.rx.allRoutineCardTap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                print("모든 루틴 탭")
                owner.coordinator?.moveToAllRoutine()
            })
            .disposed(by: disposeBag)
        
        homeView.rx.plusButtonTap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                print("플러스 버튼 탭")
                owner.coordinator?.presentWorkplaceRegistrationSheet()
            })
            .disposed(by: disposeBag)
        
        homeView.setupTableView(section: output.firstSectionData, dataSource: dataSource)
            .disposed(by: disposeBag)
    }
}

private extension HomeViewController {
    // MARK: - UIMenu Methods
    func setMenu(role: UserRole) -> UIMenu {
        let children: [UIAction] = { [weak self] in
            guard let self else { return [] }
            switch role {
            case .worker:
                return [ edit(), delete(), attendanceHistory() ]
            case .owner:
                return [ edit(), delete(), sendInvitationCode() ]
            }
        }()
        let menu = UIMenu(title: "", children: children)
        return menu
    }
    
    func edit() -> UIAction {
        let action = UIAction(title: "수정하기") { _ in
            print("수정하기")
        }
        return action
    }
    
    func delete() -> UIAction {
        let action = UIAction(title: "삭제하기") { _ in
            print("삭제하기")
        }
        return action
    }
    
    func sendInvitationCode() -> UIAction {
        let action = UIAction(title: "초대 코드 보내기") { [weak self] _ in
            guard let self else { return }
            print("초대 코드 보내기")
            self.coordinator?.presentInviteCodeSheet()
        }
        return action
    }
    
    func attendanceHistory() -> UIAction {
        let action = UIAction(title: "출퇴근 기록") { [weak self] _ in
            guard let self else { return }
            print("출퇴근 기록 확인")
            self.coordinator?.moveToAttendanceHistory(navTitle: "송눈섭") // TODO: - 알바 기준 UserDefault 등에 저장되어있는 닉네임 호출 필요
        }
        return action
    }
}

extension HomeViewController: OwnerWorkplaceCellDelegate {
    func didTapAttendanceBtn(workplaceName: String) {
        print("근태 관리 탭")
        coordinator?.moveToManageAttendance()
    }
}

extension HomeViewController: WorkerWorkplaceCellDelegate {
    func didTapStartBtn() {
        print("시작 버튼 탭")
        coordinator?.presentConfirmationModal()
    }
    
    func didTapEndBtn() {
        print("종료 버튼 탭")
    }
}
