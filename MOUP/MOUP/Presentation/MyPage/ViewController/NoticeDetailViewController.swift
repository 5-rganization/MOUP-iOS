//
//  NoticeDetailViewController.swift
//  MOUP
//
//  Created by 신영 on 11/1/25.
//

import UIKit
import RxSwift

final class NoticeDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: MyPageCoordinator?
    private let noticeDetailView = NoticeDetailView()
    private let notice: Notice
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = noticeDetailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    // MARK: - Initializer
    
    init(notice: Notice) {
        self.notice = notice
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension NoticeDetailViewController {
    // MARK: - configure
    func configure() {
        noticeDetailView.updateNotice(notice)
        setBindings()
    }
    
    // MARK: - setBindings
    func setBindings() {
        noticeDetailView.rx.backButtonTapped
            .bind(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
}
