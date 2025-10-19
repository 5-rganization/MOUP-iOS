//
//  InviteCodeInputViewController.swift
//  MOUP
//
//  Created by 송규섭 on 10/18/25.
//

import UIKit
import RxSwift

class InviteCodeInputViewController: UIViewController {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    weak var coordinator: Coordinator?
    private let inviteCodeInputView = InviteCodeInputView()
    private let viewModel: InviteCodeInputViewModel
    
    // MARK: - loadView
    override func loadView() {
        view = inviteCodeInputView
    }
    
    // MARK: - Initializer
    init(viewModel: InviteCodeInputViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    
}

private extension InviteCodeInputViewController {
    func configure() {
        setBindings()
    }
    
    func setBindings() {
        let input = InviteCodeInputViewModel.Input(
            searchBtnTapped: inviteCodeInputView.rx.searchBtnTapped.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        inviteCodeInputView.rx.navBackBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
