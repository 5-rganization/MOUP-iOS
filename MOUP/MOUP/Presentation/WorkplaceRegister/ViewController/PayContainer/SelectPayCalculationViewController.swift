//
//  SelectPayCalculationViewController.swift
//  MOUP
//
//  Created by 양원식 on 7/25/25.
//

import UIKit
import SnapKit

final class SelectPayCalculationViewController: UIViewController {
    
    // MARK: - Properties
    private let selectPayCalculationView = SelectPayCalculationView()
    // private let viewModel: <#ViewModel#>
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = selectPayCalculationView
    }
    
    // VC일 때
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK: - Initializer
    
    init() {
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

private extension SelectPayCalculationViewController {
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
        setNavigationBar(title: "급여 계산", backAction: #selector(didTapBack))
    }
    func setConstraints() { }
    func setActions() { }
    func setBinding() { }
    
}
