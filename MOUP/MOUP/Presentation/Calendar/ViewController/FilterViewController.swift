//
//  FilterViewController.swift
//  MOUP
//
//  Created by 서동환 on 7/31/25.
//

import UIKit

import RxCocoa
import RxSwift

protocol FilterVCDelegate: AnyObject {
    func dismissGestureReceived()
    func applyButtonTapped(model: FilterModel?)
}

/// 필터 VC
final class FilterViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: FilterVCDelegate?
    private let disposeBag = DisposeBag()
    
    private let viewModel: FilterViewModel
    
    // MARK: - UI Components
    private let filterView = FilterView()
    
    // MARK: - Initializer
    init(viewModel: FilterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
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
    }
    
    // MARK: - setStyles
    func setStyles() {
        self.view.backgroundColor = .primaryBackground
    }
}
