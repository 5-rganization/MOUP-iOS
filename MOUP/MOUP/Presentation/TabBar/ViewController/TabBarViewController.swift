//
//  TabBarViewController.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import Foundation

import UIKit

final class TabBarViewController: UITabBarController {
    
    // MARK: - Properties
    
    // TODO: 추후 뷰 모델 넣기
    // private let viewModel: ViewModel
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let customHeight: CGFloat = 64 + self.view.safeAreaInsets.bottom
        var tabBarFrame = self.tabBar.frame
        tabBarFrame.size.height = customHeight
        tabBarFrame.origin.y = self.view.frame.height - customHeight
        self.tabBar.frame = tabBarFrame
    }
    
    // MARK: - Initializer
    
    // TODO: 추후 뷰 모델 넣기
    init() {
        //self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        configure()
    }
    
    @available(*, unavailable, message: "Storyboard is not supported")
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}

// MARK: - UI Methods

private extension TabBarViewController {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
        setBinding()
    }
    
    func setStyles() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        let normalTextAttributes = [NSAttributedString.Key.font: UIFont.bodyMedium(12), NSAttributedString.Key.foregroundColor: UIColor.gray400]
        let selectedTextAttributes = [NSAttributedString.Key.font: UIFont.bodyMedium(12)]
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalTextAttributes
        appearance.stackedLayoutAppearance.normal.iconColor = .gray400
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedTextAttributes
        appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = .init(horizontal: 0.0, vertical: -8.0)
        appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = .init(horizontal: 0.0, vertical: -8.0)
        
        self.tabBar.standardAppearance = appearance
        self.tabBar.scrollEdgeAppearance = appearance
    }
    
    func setHierarchy() { }
    func setConstraints() { }
    func setActions() { }
    func setBinding() { }
}
