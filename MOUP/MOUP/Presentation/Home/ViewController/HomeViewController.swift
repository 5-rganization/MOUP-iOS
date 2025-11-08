//
//  HomeViewController.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import UIKit
import RxSwift
import RxRelay
import RxDataSources

final class HomeViewController: UIViewController {
    // MARK: - Properties
    weak var coordinator: HomeCoordinator?
    private let homeViewModel: HomeViewModel
    private let homeView: HomeView
    private let disposeBag = DisposeBag()
    private let refreshRelay = PublishRelay<Void>()
    private let startBtnRelay = PublishRelay<Int>() // 근무지 id
    private let endBtnRelay = PublishRelay<Int>()
    
    private lazy var dataSource = RxTableViewSectionedAnimatedDataSource<HomeTableViewFirstSection>(animationConfiguration: AnimationConfiguration(deleteAnimation: .automatic)) { dataSource, tableView, indexPath, item in
        switch item {
        case .owner(let ownerInfo):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OwnerWorkplaceCell.identifier, for: indexPath) as? OwnerWorkplaceCell else {
                return UITableViewCell()
            }
            let menu = self.setMenu(role: .owner, workplaceId: ownerInfo.workplace.id)
            cell.update(info: ownerInfo, menu: menu)
            cell.delegate = self
            return cell
        case .worker(let workerInfo):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: WorkerWorkplaceCell.identifier, for: indexPath) as? WorkerWorkplaceCell else {
                return UITableViewCell()
            }
            let menu = self.setMenu(role: .worker, workplaceId: workerInfo.homeWorkplace.workplace.id)
            cell.update(info: workerInfo, menu: menu)
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
        let input = HomeViewModel.Input(
            viewDidLoad: Observable.just(()),
            didRefresh: refreshRelay.asObservable(),
            startWorkTapped: startBtnRelay.asObservable(),
            endWorkTapped: endBtnRelay.asObservable()
        )
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
                switch owner.homeViewModel.userRole {
                case .owner:
                    owner.coordinator?.moveToDirectRegistration()
                case .worker:
                    owner.coordinator?.presentWorkplaceRegistrationSheet()
                }
            })
            .disposed(by: disposeBag)
        
        homeView.rx.refreshBtnTap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.refreshRelay.accept(())
            })
            .disposed(by: disposeBag)
        
        homeView.rx.bellButtonTap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.coordinator?.showNotificationList()
            })
            .disposed(by: disposeBag)
        
        homeView.setupTableView(section: output.firstSectionData, dataSource: dataSource)
            .disposed(by: disposeBag)
        
        output.homeHeaderData
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { owner, data in
                owner.homeView.updateHomeHeader(headerData: data)
            })
            .disposed(by: disposeBag)
        
        output.errorMessage
            .withUnretained(self)
            .subscribe(onNext: { owner, error in
                owner.presentNoticeModal(title: error.title, comment: error.message)
            })
            .disposed(by: disposeBag)
        
        output.activeWorkplace
            .withUnretained(self)
            .subscribe(onNext: { owner, workplace in
                owner.homeView.updateActiveWorkplace(workplace)
            })
            .disposed(by: disposeBag)
    }
}

private extension HomeViewController {
    // MARK: - UIMenu Methods
    func setMenu(role: UserRole, workplaceId: Int) -> UIMenu {
        let children: [UIAction] = { [weak self] in
            guard let self else { return [] }
            switch role {
            case .worker:
                return [
                    edit(id: workplaceId),
                    delete(id: workplaceId),
                    attendanceHistory(id: workplaceId)
                ]
            case .owner:
                return [
                    edit(id: workplaceId),
                    delete(id: workplaceId),
                    sendInvitationCode(id: workplaceId)
                ]
            }
        }()
        let menu = UIMenu(title: "", children: children)
        return menu
    }
    
    func edit(id workplaceId: Int) -> UIAction {
        let action = UIAction(title: "수정하기") { _ in
            print("수정하기")
        }
        return action
    }
    
    func delete(id workplaceId: Int) -> UIAction {
        let action = UIAction(title: "삭제하기") { _ in
            print("삭제하기")
        }
        return action
    }
    
    func sendInvitationCode(id workplaceId: Int) -> UIAction {
        let action = UIAction(title: "초대 코드 보내기") { [weak self] _ in
            guard let self else { return }
            print("초대 코드 보내기")
            self.coordinator?.presentInviteCodeSheet(workplaceId: workplaceId)
        }
        return action
    }
    
    func attendanceHistory(id workplaceId: Int) -> UIAction {
        let action = UIAction(title: "출퇴근 기록") { [weak self] _ in
            guard let self else { return }
            print("출퇴근 기록 확인")
            self.coordinator?.moveToAttendanceHistory(navTitle: "송눈섭", workplaceId: workplaceId) // TODO: - 알바 기준 UserDefault 등에 저장되어있는 닉네임 호출 필요
        }
        return action
    }
}

extension HomeViewController: OwnerWorkplaceCellDelegate {
    func didTapAttendanceBtn(workplaceName: String, workplaceId: Int) {
        print("근태 관리 탭")
        coordinator?.moveToManageAttendance(workplaceId: workplaceId)
    }
}

extension HomeViewController: WorkerWorkplaceCellDelegate {
    func didTapStartBtn(workplaceId: Int) {
        coordinator?.presentConfirmationModal { [weak self] in
            guard let self else { return }
            self.startBtnRelay.accept(workplaceId)
        }
    }
    
    func didTapEndBtn(workplaceId: Int) {
        self.endBtnRelay.accept(workplaceId)
    }
}
