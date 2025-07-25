//
//  ColorLabelContainerViewController.swift
//  MOUP
//
//  Created by 양원식 on 7/25/25.
//

import UIKit
import RxSwift

final class ColorLabelContainerViewController: UIViewController {
    
    // MARK: - Properties
    private let colorLabelContainerView = ColorLabelContainerView()
    private let viewModel: ColorLabelContainerViewModel
    private let disposeBag = DisposeBag()
    
    weak var coordinator: WorkplaceRegisterCoordinatorProtocol?
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = colorLabelContainerView
    }
    
    // VC일 때
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK: - Initializer
    init(
        viewModel: ColorLabelContainerViewModel,
        coordinator: WorkplaceRegisterCoordinatorProtocol?
    ) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "compile error")
    required init?(coder: NSCoder) {
        fatalError()
    }
}

// MARK: - UI Methods

private extension ColorLabelContainerViewController {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
        setBinding()
    }
    
    // MARK: - setBinding
    func setHierarchy() { }
    func setStyles() { }
    func setConstraints() { }
    func setActions() { }
    func setBinding() {
        colorLabelContainerView.getColorLabelInfoRow.rx.tap
            .bind(to: viewModel.didTapColorLabel)
            .disposed(by: disposeBag)

        viewModel.showColorLabel
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.showSelectColorLabel()
            })
            .disposed(by: disposeBag)
    }
}
