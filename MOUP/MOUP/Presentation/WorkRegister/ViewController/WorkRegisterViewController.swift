//
//  WorkRegisterViewController.swift
//  MOUP
//
//  Created by 양원식 on 8/8/25.
//

import UIKit
import RxSwift
import RxCocoa

final class WorkRegisterViewController: UIViewController {

    // MARK: - UI
    private let workRegisterView = WorkRegisterView()

    // MARK: - DI
    weak var coordinator: WorkRegisterCoordinatorProtocol?
    private let workDatePickerViewModel: WorkDatePickerViewModel
    private let clockInVM: WorkTimePickerViewModel
    private let clockOutVM: WorkTimePickerViewModel

    // MARK: - State (단일 소스)
    private var selectedWorkDate: Date = Date()
    private var clockInDate: Date?
    private var clockOutDate: Date?

    // MARK: - Etc
    private let disposeBag = DisposeBag()
    private let calendar = Calendar(identifier: .gregorian)

    // MARK: - Init
    init(
        coordinator: WorkRegisterCoordinatorProtocol,
        workDatePickerViewModel: WorkDatePickerViewModel,
        clockInVM: WorkTimePickerViewModel,
        clockOutVM: WorkTimePickerViewModel
    ) {
        self.coordinator = coordinator
        self.workDatePickerViewModel = workDatePickerViewModel
        self.clockInVM = clockInVM
        self.clockOutVM = clockOutVM
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message: "compile error")
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Life Cycle
    override func loadView() { self.view = workRegisterView }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Private
private extension WorkRegisterViewController {

    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
        setBinding()
    }

    func setHierarchy() { }

    func setStyles() {
        setNavigationBar(
            title: "새 근무 등록",
            backAction: #selector(didTapBack)
        )
    }

    func setConstraints() { }
    func setActions() { }

    // workDate(연월일) + time(시/분)을 합쳐 anchor 생성
    func anchorDate(workDate: Date, time: Date?) -> Date {
        let base = time ?? Date()
        var d = calendar.dateComponents([.year, .month, .day], from: workDate)
        let t = calendar.dateComponents([.hour, .minute], from: base)
        d.hour = t.hour; d.minute = t.minute; d.second = 0
        return calendar.date(from: d) ?? workDate
    }

    func setBinding() {

        // 근무지
        workRegisterView.rx.selectWorkplaceTap
            .bind(onNext: { print("근무지 선택 버튼 클릭") })
            .disposed(by: disposeBag)

        // 날짜 피커
        workRegisterView.rx.workDateTap
            .bind(onNext: { [weak self] in
                guard let self else { return }
                let vc = WorkDatePickerViewController(viewModel: self.workDatePickerViewModel)

                self.workDatePickerViewModel.confirmSelectedDate
                    .do(onNext: { [weak self] d in self?.selectedWorkDate = d }) // 상태 저장
                    .map { DateFormatter.dataSourceDateFormatter.string(from: $0) }
                    .observe(on: MainScheduler.instance)
                    .take(until: vc.rx.deallocated) // 구독 누적 방지
                    .bind(to: self.workRegisterView.rx.selectedWorkDateText)
                    .disposed(by: self.disposeBag)

                self.present(vc, animated: true)
            })
            .disposed(by: disposeBag)

        // 반복
        workRegisterView.rx.repetitionTap
            .bind(onNext: { print("반복 버튼 클릭") })
            .disposed(by: disposeBag)

        // 출근 시간
        workRegisterView.rx.clockInTap
            .bind(onNext: { [weak self] in
                guard let self else { return }
                let anchor = self.anchorDate(workDate: self.selectedWorkDate, time: self.clockInDate)
                self.clockInVM.reconfigure(anchorDate: anchor, confirmedDate: self.clockInDate)

                let vc = WorkTimePickerViewController(viewModel: self.clockInVM)

                self.clockInVM.confirmSelectedTime
                    .do(onNext: { [weak self] d in self?.clockInDate = d }) // 상태 저장
                    .map { DateFormatter.ko12hTimeFormatter.string(from: $0) }
                    .observe(on: MainScheduler.instance)
                    .take(until: vc.rx.deallocated)
                    .bind(to: self.workRegisterView.rx.selectedClockInTimeText)
                    .disposed(by: self.disposeBag)

                self.clockInVM.confirmSelectedTime
                    .take(1)
                    .take(until: vc.rx.deallocated)
                    .bind(onNext: { [weak vc] _ in vc?.dismiss(animated: true) })
                    .disposed(by: self.disposeBag)

                self.clockInVM.dismiss
                    .take(until: vc.rx.deallocated)
                    .bind(onNext: { [weak vc] in vc?.dismiss(animated: true) })
                    .disposed(by: self.disposeBag)

                self.present(vc, animated: true)
            })
            .disposed(by: disposeBag)

        // 퇴근 시간
        workRegisterView.rx.clockOutTap
            .bind(onNext: { [weak self] in
                guard let self else { return }
                let anchor = self.anchorDate(workDate: self.selectedWorkDate, time: self.clockOutDate)
                self.clockOutVM.reconfigure(anchorDate: anchor, confirmedDate: self.clockOutDate)

                let vc = WorkTimePickerViewController(viewModel: self.clockOutVM)

                self.clockOutVM.confirmSelectedTime
                    .do(onNext: { [weak self] d in self?.clockOutDate = d })
                    .map { DateFormatter.ko12hTimeFormatter.string(from: $0) }
                    .observe(on: MainScheduler.instance)
                    .take(until: vc.rx.deallocated)
                    .bind(to: self.workRegisterView.rx.selectedClockOutTimeText)
                    .disposed(by: self.disposeBag)

                self.clockOutVM.confirmSelectedTime
                    .take(1)
                    .take(until: vc.rx.deallocated)
                    .bind(onNext: { [weak vc] _ in vc?.dismiss(animated: true) })
                    .disposed(by: self.disposeBag)

                self.clockOutVM.dismiss
                    .take(until: vc.rx.deallocated)
                    .bind(onNext: { [weak vc] in vc?.dismiss(animated: true) })
                    .disposed(by: self.disposeBag)

                self.present(vc, animated: true)
            })
            .disposed(by: disposeBag)

        // 휴게 시간
        workRegisterView.rx.lunchBreakTap
            .bind(onNext: { print("휴게 버튼 클릭") })
            .disposed(by: disposeBag)
        
        // 루틴/컬러
        workRegisterView.rx.routinTap
            .bind(onNext: { print("루틴 추가 버튼 클릭") })
            .disposed(by: disposeBag)

        workRegisterView.rx.colorTap
            .bind(onNext: { [weak self] in
                print("컬러 선택 버튼 클릭")
                self?.coordinator?.showSelectColorLabel()
            })
            .disposed(by: disposeBag)
    }
}
