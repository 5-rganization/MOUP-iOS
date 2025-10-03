//
//  AttendanceConfirmModalViewController.swift
//  MOUP
//
//  Created by 송규섭 on 10/2/25.
//

import UIKit
import RxSwift

final class AttendanceConfirmModalViewController: UIViewController {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let confirmModalView = ConfirmationModal()
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

}

private extension AttendanceConfirmModalViewController {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setBindings()
    }
    
    func setHierarchy() {
        view.addSubviews(confirmModalView) // 뒤 dimmedView를 쓰려면 loadView 대신 서브뷰 추가 방식 채택
    }
    
    func setStyles() {
        view.backgroundColor = .gray900.withAlphaComponent(0.5)
        
        confirmModalView.update(
            title: "지금 출근하셨나요?",
            comment: "출근 시간은 나중에 수정할 수 있어요.\n지금 등록할까요?"
        )
    }
    
    func setConstraints() {
        confirmModalView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func setBindings() {
        confirmModalView.rx.confirmBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        confirmModalView.rx.cancelBtnTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
