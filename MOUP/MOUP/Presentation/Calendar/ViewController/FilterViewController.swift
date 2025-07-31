//
//  FilterViewController.swift
//  MOUP
//
//  Created by 서동환 on 7/31/25.
//

import UIKit

import RxCocoa
import RxSwift

/// 필터 VC
final class FilterViewController: UIViewController {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let filterView = FilterView()
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = filterView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

private extension FilterViewController {
    // MARK: - configure
    func configure() {
        setStyles()
        setBinding()
    }
    
    // MARK: - setStyles
    func setStyles() {
        self.view.backgroundColor = .primaryBackground
    }
    
    // MARK: - setBinding
    func setBinding() {
        filterView.rx.applyButtonTap
            .subscribe(with: self) { owner, _ in
                
                owner.dismiss(animated: true)
            }.disposed(by: disposeBag)
    }
}
