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
    weak var coordinator: InviteCodeInputCoordinator?
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
        setDelegate()
    }
    
    func setBindings() {
        let input = InviteCodeInputViewModel.Input(
            searchBtnTapped: inviteCodeInputView.rx.searchBtnTapped.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output.searchResult
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { owner, workplace in
                guard let workplace,
                let inviteCode = owner.inviteCodeInputView.getInviteCode() else { return }
                owner.coordinator?.moveToInviteCodeResult(workplace: workplace, inviteCode: inviteCode)
            })
            .disposed(by: disposeBag)
        
        output.errorMessage
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { owner, message in
                owner.presentNoticeModal(title: message.0, comment: message.1)
            })
            .disposed(by: disposeBag)
        
        inviteCodeInputView.rx.navBackBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        
    }
    
    func setDelegate() {
        inviteCodeInputView.setTextFieldDelegate(self)
    }
}

extension InviteCodeInputViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        return string.rangeOfCharacter(from: allowedCharacters.inverted) == nil
    }
}
