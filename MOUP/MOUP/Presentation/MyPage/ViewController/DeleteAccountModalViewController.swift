//
//  DeleteAccountModalViewController.swift
//  MOUP
//
//  Created by shinyoungkim on 7/25/25.
//

import UIKit
import RxSwift

final class DeleteAccountModalViewController: UIViewController {
    
    // MARK: - Properties
    
    private var hasAnimatedIn = false
    private let viewModel: DeleteAccountViewModel
    private let disposeBag = DisposeBag()
    
    private let viewDidLoadSubject = PublishSubject<Void>()
    
    // MARK: - UI Components
    
    private let deleteAccountModal = DeleteAccountModal().then {
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        $0.layer.masksToBounds = true
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        
        viewDidLoadSubject.onNext(())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !hasAnimatedIn {
            hasAnimatedIn = true
            animateModalIn()
        }
    }
    
    // MARK: - Initializer
    
    init(viewModel: DeleteAccountViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension DeleteAccountModalViewController {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setBindings()
        setGestureRecognizers()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        view.addSubview(deleteAccountModal)
    }
    
    // MARK: - setStyles
    func setStyles() {
        view.backgroundColor = .modalBackground
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        deleteAccountModal.snp.makeConstraints {
            $0.height.equalTo(348)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    // MARK: - setBindings
    func setBindings() {
        deleteAccountModal.rx.cancelButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.animateModalOut {
                    owner.dismiss(animated: false)
                }
            })
            .disposed(by: disposeBag)
        
        deleteAccountModal.rx.draggedToDismiss
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.animateModalOut {
                    owner.dismiss(animated: false)
                }
            })
            .disposed(by: disposeBag)
        
        let input = DeleteAccountViewModel.Input(
            viewDidLoad: viewDidLoadSubject.asObservable(),
            deleteTap: deleteAccountModal.rx.deleteAccountButtonTapped.asObservable()
        )
        
        let output = viewModel.transform(input)
        
        output.nickname
            .filter { !$0.isEmpty }
            .drive(with: self) { owner, nickname in
                owner.deleteAccountModal.updateNickname(nickname)
            }
            .disposed(by: disposeBag)
        
        output.deleteSuccess
            .withUnretained(self)
            .emit(onNext: { owner, _ in
                owner.animateModalOut {
                    owner.dismiss(animated: false) {
                        NotificationCenter.default.post(
                            name: .deleteAccountSuccess,
                            object: nil
                        )
                    }
                }
            })
            .disposed(by: disposeBag)
        
        output.errorMessage
            .withUnretained(self)
            .emit(onNext: { owner, errorMessage in
                let alert = NoticeModalViewController(
                    title: "회원 탈퇴 실패",
                    comment: errorMessage
                )
                owner.present(alert, animated: false)
            })
            .disposed(by: disposeBag)
        
        output.isDeleting
            .drive(with: self) { owner, isDeleting in
                print(isDeleting ? "회원 탈퇴 중..." : "처리 완료")
            }
            .disposed(by: disposeBag)
    }
    
    func setGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(backgroundDidTap(_:))
        )
        view.addGestureRecognizer(tapGesture)
    }

    @objc func backgroundDidTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        
        if deleteAccountModal.frame.contains(location) == false {
            animateModalOut {
                self.dismiss(animated: false)
            }
        }
    }
}

private extension DeleteAccountModalViewController {
    func animateModalIn() {
        deleteAccountModal.transform = CGAffineTransform(
            translationX: 0,
            y: deleteAccountModal.frame.height
        )
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut]) {
            self.deleteAccountModal.transform = .identity
        }
    }
    
    func animateModalOut(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.25, animations: {
            self.deleteAccountModal.transform = CGAffineTransform(translationX: 0, y: self.deleteAccountModal.frame.height)
        }, completion: { _ in
            completion?()
        })
    }
}
