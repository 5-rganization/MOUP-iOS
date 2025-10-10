//
//  InviteCodeSheetViewController.swift
//  MOUP
//
//  Created by 송규섭 on 9/28/25.
//

import UIKit
import RxSwift

final class InviteCodeSheetViewController: UIViewController {
    // MARK: - Properties
    private let inviteCodeSheetView = InviteCodeSheetView()
    private let viewModel: InviteCodeSheetViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - loadView
    override func loadView() {
        view = inviteCodeSheetView
    }
    
    // MARK: - Initializer
    init(viewModel: InviteCodeSheetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
}

private extension InviteCodeSheetViewController {
    func configure() {
        setBindings()
    }
    
    func setBindings() {
        inviteCodeSheetView.rx.copyBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                
            })
            .disposed(by: disposeBag)
    }
}
