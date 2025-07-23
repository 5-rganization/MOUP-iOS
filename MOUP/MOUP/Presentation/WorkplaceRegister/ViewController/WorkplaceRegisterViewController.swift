//
//  WorkplaceRegisterViewController.swift
//  MOUP
//
//  Created by 양원식 on 7/15/25.
//

import UIKit

final class WorkplaceRegisterViewController: UIViewController {
    
    // MARK: - Properties
    private let workplaceRegisterView = WorkplaceRegisterView()
    private let workingConditionsContainerVC: WorkingConditionsContainerViewController
    // private let viewModel: <#ViewModel#>
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = workplaceRegisterView
    }
    
    // VC일 때
    override func viewDidLoad() {
        super.viewDidLoad()
        add(child: workingConditionsContainerVC, to: workplaceRegisterView.getWorkingConditionsContainerView)
        configure()
    }
    
    // MARK: - Initializer
    
    init(workingConditionsContainerViewModel: WorkingConditionsContainerViewModel) {
        self.workingConditionsContainerVC = WorkingConditionsContainerViewController(viewModel: workingConditionsContainerViewModel)
        super.init(nibName: nil, bundle: nil)
    }

    
    @available(*, unavailable, message: "compile error")
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc
    private func didTapBack() {
        print("Back 버튼 클릭")
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UI Methods

private extension WorkplaceRegisterViewController {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
        setBinding()
    }
    
    // MARK: - setBinding
    func setHierarchy() { }
    func setStyles() {
        setNavigationBar(title: "근무지 등록", backAction: #selector(didTapBack))
    }
    func setConstraints() { }
    func setActions() { }
    func setBinding() { }
    
}
