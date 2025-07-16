//
//  HomeViewController.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import UIKit

final class HomeViewController: UIViewController {
    weak var coordinator: HomeCoordinator?
    private let homeViewModel: HomeViewModel
    private let homeView = HomeView()


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

    }
}
