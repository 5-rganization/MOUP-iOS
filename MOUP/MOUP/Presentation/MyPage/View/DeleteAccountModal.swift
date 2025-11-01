//
//  DeleteAccountModal.swift
//  MOUP
//
//  Created by shinyoungkim on 7/25/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

final class DeleteAccountModal: UIView {
    
    // MARK: - Properties
    
    fileprivate let dragToDismissSubject = PublishSubject<Void>()
    
    // MARK: - UI Components
    
    private let handleBar = UIView().then {
        $0.backgroundColor = .gray400
        $0.layer.cornerRadius = 2
        $0.clipsToBounds = true
    }
    
    private let handleView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "님, 탈퇴 전에 확인해주세요!"
        $0.font = .headBold(16)
        $0.setLineSpacing(.bodyMedium)
        $0.textColor = .gray900
    }
    
    private let descriptionLabel = UILabel().then {
        $0.text = "탈퇴일 포함 3일 동안은 재가입할 수 없으며,\n재가입하더라도 이전 이용 내역은 복구되지 않습니다."
        $0.font = .bodyMedium(16)
        $0.setLineSpacing(.bodyMedium)
        $0.textColor = .gray700
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    private let confirmLabel = UILabel().then {
        $0.text = "탈퇴를 진행할까요?"
        $0.font = .headBold(16)
        $0.setLineSpacing(.bodyMedium)
        $0.textColor = .gray900
    }
    
    private let deleteAccountNoticeStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .center
    }
    
    fileprivate let cancelButton = UIButton().then {
        $0.titleLabel?.font = .buttonSemibold(18)
        $0.setTitleColor(.gray600, for: .normal)
        $0.setTitle("아뇨, 안할래요", for: .normal)
        $0.backgroundColor = .gray200
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    fileprivate let deleteAccountButton = UIButton().then {
        $0.titleLabel?.font = .buttonSemibold(18)
        $0.setTitleColor(.white, for: .normal)
        $0.setTitle("탈퇴할게요", for: .normal)
        $0.backgroundColor = .primary500
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }

    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func updateNickname(_ nickname: String) {
        titleLabel.text = "\(nickname)님, 탈퇴 전에 확인해주세요!"
    }
}

private extension DeleteAccountModal {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setGestures()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            handleView,
            deleteAccountNoticeStackView,
            cancelButton,
            deleteAccountButton
        )
        
        handleView.addSubview(handleBar)
        
        deleteAccountNoticeStackView.addArrangedSubviews(
            titleLabel,
            descriptionLabel,
            confirmLabel
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        handleBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.width.equalTo(45)
            $0.height.equalTo(4)
            $0.centerX.equalToSuperview()
        }
        
        handleView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.height.equalTo(28)
        }
        
        deleteAccountNoticeStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(48)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(deleteAccountNoticeStackView.snp.bottom).offset(36)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }
        
        deleteAccountButton.snp.makeConstraints {
            $0.top.equalTo(cancelButton.snp.bottom).offset(8)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }
    }
    
    // MARK: - setGestures()
    func setGestures() {
        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(handleDrag(_:))
        )
        handleView.addGestureRecognizer(panGesture)
    }
    
    @objc func handleDrag(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)

        switch gesture.state {
        case .changed:
            if translation.y > 0 {
                self.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }
        case .ended, .cancelled:
            if translation.y > 100 {
                dragToDismissSubject.onNext(())
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.transform = .identity
                })
            }
        default:
            break
        }
    }
}

extension Reactive where Base: DeleteAccountModal {
    var cancelButtonTapped: ControlEvent<Void> {
        base.cancelButton.rx.tap
    }
    
    var draggedToDismiss: ControlEvent<Void> {
        ControlEvent(events: base.dragToDismissSubject)
    }
    
    var deleteAccountButtonTapped: ControlEvent<Void> {
        base.deleteAccountButton.rx.tap
    }
}
