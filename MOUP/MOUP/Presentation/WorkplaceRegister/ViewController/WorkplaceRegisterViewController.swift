//
//  WorkplaceRegisterViewController.swift
//  MOUP
//
//  Created by 양원식 on 7/15/25.
//

import UIKit

final class WorkplaceRegisterViewController: UIViewController {
    
    // MARK: - Properties
    
    // private let viewModel: <#ViewModel#>
    
    // MARK: - Lifecycle
    
    // VC일 때
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK: - Initializer
    
    
    @available(*, unavailable, message: "compile error")
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc
    func didTapSomeButton(_ sender: UIButton) {
        
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
    // ...
    
    // MARK: - setBinding
    func setHierarchy() { }
    func setStyles() { }
    func setConstraints() { }
    func setActions() { }
    func setBinding() { }
    
}
