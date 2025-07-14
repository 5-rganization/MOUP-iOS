//
//  TabBarCoordinator.swift
//  MOUP
//
//  Created by 양원식 on 7/14/25.
//
import UIKit

final class TabBarCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    let window: UIWindow
    let tabBarController = TabBarViewController()

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        // 각 탭의 네비게이션 컨트롤러와 코디네이터 생성
        let homeNav = UINavigationController()
        let homeCoordinator = HomeCoordinator(navigationController: homeNav)
        childCoordinators.append(homeCoordinator)
        homeCoordinator.start()

        let calendarNav = UINavigationController()
        let calendarCoordinator = CalendarCoordinator(navigationController: calendarNav)
        childCoordinators.append(calendarCoordinator)
        calendarCoordinator.start()

        let myPageNav = UINavigationController()
        let myPageCoordinator = MyPageCoordinator(navigationController: myPageNav)
        childCoordinators.append(myPageCoordinator)
        myPageCoordinator.start()

        // 탭바에 네비게이션 컨트롤러 추가
        tabBarController.setViewControllers([homeNav, calendarNav, myPageNav], animated: false)

        // window의 rootViewController로 설정
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}

