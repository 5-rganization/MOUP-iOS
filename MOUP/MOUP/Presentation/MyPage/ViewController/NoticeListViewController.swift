//
//  NoticeListViewController.swift
//  MOUP
//
//  Created by 신영 on 11/1/25.
//

import UIKit
import RxSwift

final class NoticeListViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: MyPageCoordinator?
    private let noticeListView = NoticeListView()
    private let viewModel: NoticeListViewModel
    private let disposeBag = DisposeBag()
    
    private let viewDidLoadSubject = PublishSubject<Void>()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = noticeListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        viewDidLoadSubject.onNext(())
    }
    
    // MARK: - Initializer
    
    init(viewModel: NoticeListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension NoticeListViewController {
    // MARK: - configure
    func configure() {
        setBindings()
    }
    
    // MARK: - setBindings
    func setBindings() {
        noticeListView.rx.backButtonTapped
            .bind(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        noticeListView.rx.noticeTapped
            .bind(with: self) { owner, notice in
                owner.coordinator?.showNoticeDetail(notice)
            }
            .disposed(by: disposeBag)
        
        let input = NoticeListViewModel.Input(
            viewDidLoad: viewDidLoadSubject.asObservable()
        )
        
        let output = viewModel.transform(input)
        
        output.isLoading
            .drive(with: self) { owner, isLoading in
                if isLoading {
                    owner.noticeListView.showLoading()
                } else {
                    owner.noticeListView.hideLoading()
                }
            }
            .disposed(by: disposeBag)
        
        output.notices
            .drive(with: self) { owner, notices in
                owner.noticeListView.updateNotices(notices)
            }
            .disposed(by: disposeBag)
        
        output.error
            .emit(with: self) { owner, message in
                print("에러: \(message)")
                
                let alert = NoticeModalViewController(
                    title: "일시적인 오류가 발생했습니다.",
                    comment: message
                )
            }
            .disposed(by: disposeBag)
    }
}
