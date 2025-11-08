//
//  TabBarCoordinator.swift
//  MOUP
//
//  Created by 양원식 on 7/14/25.
//
import UIKit

final class TabBarCoordinator: Coordinator {
    weak var coordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    private let window: UIWindow
    private let tabBarViewModel: TabBarViewModel
    private let tabBarController: TabBarViewController
    private let userRole: UserRole

    init(
        coordinator: Coordinator,
        window: UIWindow,
        authUseCase: AuthUseCaseProtocol,
        userRole: UserRole
    ) {
        self.coordinator = coordinator
        self.window = window
        self.tabBarViewModel = TabBarViewModel(authUseCase: authUseCase)
        self.tabBarController = TabBarViewController(viewModel: tabBarViewModel)
        self.userRole = userRole
    }

    func start() {
        // Home
        let homeNav = UINavigationController()
        let homeCoordinator = HomeCoordinator(
            navigationController: homeNav,
            userRole: userRole
        )
        childCoordinators.append(homeCoordinator)
        homeCoordinator.start()

        if let homeVC = homeNav.viewControllers.first {
            homeVC.tabBarItem = UITabBarItem(
                title: "홈",
                image: .homeUnselected,
                selectedImage: .homeSelected.withRenderingMode(.alwaysOriginal)
            )
        }

        // Calendar
        let calendarNav = UINavigationController()
        let calendarCoordinator = CalendarCoordinator(navigationController: calendarNav)
        childCoordinators.append(calendarCoordinator)
        calendarCoordinator.start()

        if let calendarVC = calendarNav.viewControllers.first {
            calendarVC.tabBarItem = UITabBarItem(
                title: "캘린더",
                image: .calendarUnselected,
                selectedImage: .calendarSelected.withRenderingMode(.alwaysOriginal)
            )
        }

        // MyPage
        let myPageNav = UINavigationController()
        let myPageCoordinator = MyPageCoordinator(navigationController: myPageNav)
        childCoordinators.append(myPageCoordinator)
        myPageCoordinator.start()

        if let myPageVC = myPageNav.viewControllers.first {
            myPageVC.tabBarItem = UITabBarItem(
                title: "마이페이지",
                image: .myPageUnselected,
                selectedImage: .myPageSelected.withRenderingMode(.alwaysOriginal)
            )
        }

        // 탭바 연결
        tabBarController.setViewControllers([homeNav, calendarNav, myPageNav], animated: false)

        // 루트 설정
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: { [weak self] in
            guard let self else { return }
            window.rootViewController = tabBarController
        })
        
        window.makeKeyAndVisible()
    }
    
    func moveToNotificationList() {
        tabBarController.selectedIndex = 2
        
        guard let myPageCoordinator = childCoordinators.first(where: { $0 is MyPageCoordinator }) as? MyPageCoordinator else {
            print("MypageCoordinator를 찾을 수 없습니다.")
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            myPageCoordinator.showNotificationList()
            print("알림 리스트 화면으로 이동 완료")
        }
    }
}


