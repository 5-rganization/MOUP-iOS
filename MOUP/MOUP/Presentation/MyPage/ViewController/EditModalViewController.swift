//
//  EditModalViewController.swift
//  MOUP
//
//  Created by shinyoungkim on 8/11/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

final class EditModalViewController: UIViewController {
    
    // MARK: - Properties
    
    private var bottomConstraint: Constraint?
    private let saveButtonDidTapSubject = PublishSubject<Void>()
    var onNicknameSaved: ((String) -> Void)?
    private let disposeBag = DisposeBag()
    private let viewModel: EditModalViewModel
    
    // MARK: - UI Components
    
    private let editModal = EditModal().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    private let closeButton = UIButton().then {
        $0.setImage(UIImage.xMark, for: .normal)
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        editModal.focusTextField()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        registerKeyboardNotifications()
    }
    
    // MARK: - Initializer
    
    init(viewModel: EditModalViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension EditModalViewController {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setBindings()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        view.addSubviews(
            closeButton,
            editModal
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        view.backgroundColor = .modalBackground
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        closeButton.snp.makeConstraints {
            $0.bottom.equalTo(editModal.snp.top)
            $0.trailing.equalTo(editModal.snp.trailing)
        }
        
        editModal.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.equalTo(225)
            $0.width.equalTo(343)
            self.bottomConstraint = $0.bottom.equalTo(view.safeAreaLayoutGuide).constraint
        }
    }
    
    private func registerKeyboardNotifications() {
        let willShow = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
        let willHide = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)

        willShow
            .compactMap { $0.userInfo }
            .bind(with: self) { owner, info in
                let frame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
                let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
                let bottomSafe = owner.view.safeAreaInsets.bottom
                owner.bottomConstraint?.update(inset: max(0, frame.height - bottomSafe + 32))
                UIView.animate(withDuration: duration) { owner.view.layoutIfNeeded() }
            }
            .disposed(by: disposeBag)

        willHide
            .compactMap { $0.userInfo }
            .bind(with: self) { owner, info in
                let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
                owner.bottomConstraint?.update(inset: 0)
                UIView.animate(withDuration: duration) { owner.view.layoutIfNeeded() }
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - setBindings
    func setBindings() {
//        editModal.rx.saveButtonTapped
//            .bind(with: self) { owner, _ in
//                owner.saveButtonDidTapSubject.onNext(())
//            }
//            .disposed(by: disposeBag)
        
        closeButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: false)
            }
            .disposed(by: disposeBag)
        
        let input = EditModalViewModel
    }
}
