//
//  DeleteAccountModalViewController.swift
//  MOUP
//
//  Created by shinyoungkim on 7/25/25.
//

import UIKit

final class DeleteAccountModalViewController: UIViewController {
    
    // MARK: - Properties
    
    private var hasAnimatedIn = false
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !hasAnimatedIn {
            hasAnimatedIn = true
            animateModalIn()
        }
    }
}

private extension DeleteAccountModalViewController {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
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
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
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
