//
//  RepeatSettingViewController.swift
//  MOUP
//
//  Created by 양원식 on 11/15/25.
//

import UIKit
import RxSwift
import RxCocoa

final class RepeatSettingViewController: UIViewController {
    
    // MARK: - UI
    private let repeatSettingView = RepeatSettingView()
    private let viewModel: RepeatSettingViewModel
    // MARK: - Etc
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = repeatSettingView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK: - Initializer
    init(viewModel: RepeatSettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}


// MARK: - UI Methods
private extension RepeatSettingViewController {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
        setBinding()
    }

    func setHierarchy() { }
    
    func setStyles() { }
    
    func setConstraints() { }
    
    func setActions() {
            // 날짜 선택 탭
            repeatSettingView.rx.dateTap
                .bind { [weak self] in
                    guard let self else { return }
                    
                    let dateVM = WorkDatePickerViewModel()
                    let dateVC = WorkDatePickerViewController(viewModel: dateVM)
                    
                    // 날짜 선택 완료
                    dateVM.confirmSelectedDate
                        .take(until: dateVC.rx.deallocated)
                        .observe(on: MainScheduler.instance)
                        .bind(onNext: { [weak self] date in
                            guard let self else { return }
                            // UI 업데이트
                            let dateStr = DateFormatter.dataSourceDateFormatter.string(from: date)
                            self.repeatSettingView.updateDateText(dateStr)
                            
                            // ViewModel에 날짜 선택 전달
                            self.viewModel.dateSelected.accept(date)
                        })
                        .disposed(by: disposeBag)
                    
                    self.present(dateVC, animated: true)
                }
                .disposed(by: disposeBag)
            
            // 요일 선택 → ViewModel에 전달
            repeatSettingView.rx.dayTap
                .bind(to: viewModel.didTapDay)
                .disposed(by: disposeBag)
        }
        
    func setBinding() {
        repeatSettingView.rx.navBackBtnTapped.asDriver()
            .drive(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)

        // 기존 날짜 유지 → UI 표시
        viewModel.selectedDate
            .compactMap { $0 }
            .map { DateFormatter.dataSourceDateFormatter.string(from: $0) }
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] text in
                self?.repeatSettingView.updateDateText(text)
            })
            .disposed(by: disposeBag)

        // 기존 요일 선택 유지 → UI 버튼 선택 상태 반영
        viewModel.selectedDays
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] set in
                self?.repeatSettingView.updateSelectedDays(set)
            })
            .disposed(by: disposeBag)

        // 버튼 활성화
        viewModel.isFormValid
            .drive(repeatSettingView.registerButton.rx.isEnabled)
            .disposed(by: disposeBag)

        // 버튼 탭 → ViewModel 처리
        repeatSettingView.rx.registerTap
            .bind(to: viewModel.didTapRegister)
            .disposed(by: disposeBag)

        // 완료 이벤트 → VC에서 pop
        viewModel.didCompleteRepeatSetting
            .bind(onNext: { [weak self] info in
                guard let self else { return }
                print("반복 설정 완료:", info)
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

