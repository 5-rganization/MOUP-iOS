//
//  WorkRegisterViewController.swift
//  MOUP
//
//  Created by 양원식 on 8/8/25.
//

import UIKit
import RxSwift

final class WorkRegisterViewController: UIViewController {
    
    // MARK: - Properties
    private let workRegisterView = WorkRegisterView()
    private let coordinator: WorkRegisterCoordinatorProtocol
    private let disposeBag = DisposeBag()
    
    //private let viewModel: <#ViewModel#>
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = workRegisterView
    }
    
    // VC일 때
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK: - Initializer
    
    init(
        coordinator: WorkRegisterCoordinatorProtocol
    ) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "compile error")
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc
    private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UI Methods

private extension WorkRegisterViewController {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
        setBinding()
    }
    
    // MARK: - setBinding
    func setHierarchy() { }
    func setStyles() {
        setNavigationBar(
            title: "새 근무 등록",
            backAction: #selector(didTapBack)
        )
    }
    func setConstraints() { }
    func setActions() { }
    func setBinding() {
        workRegisterView.rx.selectWorkplaceTap
            .bind(onNext: {
                print("근무지 선택 버튼 클릭")
            })
            .disposed(by: disposeBag)
        
        workRegisterView.rx.workDateTap
            .bind(onNext: {
                print("날짜 버튼 클릭")
            })
            .disposed(by: disposeBag)
        
        workRegisterView.rx.repetitionTap
            .bind(onNext: {
                print("반복 버튼 클릭")
            })
            .disposed(by: disposeBag)
        
        workRegisterView.rx.clockInTap
            .bind(onNext: {
                print("출근 버튼 클릭")
            })
            .disposed(by: disposeBag)
        
        workRegisterView.rx.clockOutTap
            .bind(onNext: {
                print("퇴근 버튼 클릭")
            })
            .disposed(by: disposeBag)
        
        workRegisterView.rx.lunchBreakTap
            .bind(onNext: {
                print("휴게 버튼 클릭")
            })
            .disposed(by: disposeBag)
        
        workRegisterView.rx.routinTap
            .bind(onNext: {
                print("루틴 추가 버튼 클릭")
            })
            .disposed(by: disposeBag)
    }
    
}
