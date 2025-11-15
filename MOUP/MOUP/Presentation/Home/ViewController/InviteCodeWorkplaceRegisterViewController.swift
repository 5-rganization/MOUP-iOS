//
//  InviteCodeWorkplaceRegisterViewController.swift
//  MOUP
//
//  Created by 양원식 on 11/15/25.
//

import UIKit

final class InviteCodeWorkplaceRegisterViewController: UIViewController {
    
    // MARK: - Properties
    private let workplaceName: String
    private let inviteCode: String
    //private let viewModel: <#ViewModel#>
    
    // MARK: - Lifecycle
    
    // VC일 때
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK: - Initializer
    
    init(workplaceName: String, inviteCode: String) {
        self.workplaceName = workplaceName
        self.inviteCode = inviteCode
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "compile error")
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UI Methods

private extension InviteCodeWorkplaceRegisterViewController {
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
        setNavigationBar(
            title: workplaceName,
            backAction: #selector(didTapBack)
        )
    }
    func setConstraints() { }
    func setActions() { }
    func setBinding() { }
    
}
