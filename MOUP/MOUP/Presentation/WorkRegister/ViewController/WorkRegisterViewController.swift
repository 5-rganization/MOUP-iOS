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
    private let viewModel: WorkRegisterViewModel
    private weak var coordinator: WorkRegisterCoordinatorProtocol?

    // MARK: - State
    private var selectedWorkDate: Date = Date()
    private var clockInDate: Date?
    private var clockOutDate: Date?

    // MARK: - Etc
    private let disposeBag = DisposeBag()
    private let calendar = Calendar.current

    // MARK: - Init
    init(
        viewModel: WorkRegisterViewModel,
        coordinator: WorkRegisterCoordinatorProtocol
    ) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message: "Storyboard is not supported.")
    required init?(coder: NSCoder) { fatalError("Storyboard is not supported.") }

    // MARK: - Life Cycle
    override func loadView() { self.view = workRegisterView }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.viewWillDisappear.accept(())
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

    func setStyles() { }

    func setConstraints() { }
    func setActions() { }

    /// workDate(연월일) + time(시/분)을 합쳐 anchor 생성
    func anchorDate(workDate: Date, time: Date?) -> Date {
        let base = time ?? Date()
        var d = calendar.dateComponents([.year, .month, .day], from: workDate)
        let t = calendar.dateComponents([.hour, .minute], from: base)
        d.hour = t.hour; d.minute = t.minute; d.second = 0
        return calendar.date(from: d) ?? workDate
    }

    // MARK: - Binding
    func setBinding() {
        workRegisterView.rx.navBackBtnTapped.asDriver()
            .drive(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)
        
        // MARK: - 근무지
        workRegisterView.rx.selectWorkplaceTap
            .bind(onNext: { [weak self] in
                self?.coordinator?.showSelectWorkplace()
            })
            .disposed(by: disposeBag)
        
        viewModel.selectedWorkplaceVM.confirmSelectedWorkplace
            .map { $0.name } // 선택된 근무지의 이름만 추출
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] name in
                self?.workRegisterView.getSelectWorkplace.updateAttributedTitle(to: name)
            })
            .disposed(by: disposeBag)

        // MARK: - 날짜 선택
        viewModel.selectedDate.asDriver()
            .drive(with: self, onNext: { owner, date in
                let dateStr = DateFormatter.dataSourceDateFormatter.string(from: date)
                owner.workRegisterView.rx.selectedWorkDateText.onNext(dateStr)
            }).disposed(by: disposeBag)
        
        workRegisterView.rx.workDateTap
            .bind(onNext: { [weak self] in
                guard let self else { return }

                let vc = WorkDatePickerViewController(viewModel: viewModel.datePickerVM)

                viewModel.datePickerVM.confirmSelectedDate
                    .do(onNext: { [weak self] d in self?.selectedWorkDate = d })
                    .map { DateFormatter.dataSourceDateFormatter.string(from: $0) }
                    .observe(on: MainScheduler.instance)
                    .take(until: vc.rx.deallocated)
                    .bind(to: workRegisterView.rx.selectedWorkDateText)
                    .disposed(by: disposeBag)

                present(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        // MARK: - 반복 선택
        workRegisterView.rx.repetitionTap
            .bind(onNext: { [weak self] in
                guard let self else { return }

                let vm = self.viewModel.repeatSettingVM
                let info = self.viewModel.repeatInfo.value

                // 기존 반복값을 RepeatViewModel 에 전달
                vm.configureInitial(
                    endDate: info?.endDate,
                    daysIndex: info?.daysIndex
                )

                self.coordinator?.showRepeatSetting()
            })
            .disposed(by: disposeBag)

        
        // 반복 설정 완료 값 구독
        viewModel.repeatInfo
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] repeatInfo in
                guard let self else { return }

                // repeatInfo == nil → "없음" 처리
                guard let info = repeatInfo else {
                    self.workRegisterView.setRepetitionText("없음")
                    return
                }

                let days = info.daysIndex
                let weekKR = ["일", "월", "화", "수", "목", "금", "토"]

                let krText = days.map { weekKR[$0] }.joined(separator: " / ")

                self.workRegisterView.setRepetitionText(krText)
            })
            .disposed(by: disposeBag)



        // MARK: - 출근 시간
        workRegisterView.rx.clockInTap
            .bind(onNext: { [weak self] in
                guard let self else { return }

                let vm = viewModel.clockInVM
                let anchor = anchorDate(workDate: selectedWorkDate, time: clockInDate)
                vm.reconfigure(anchorDate: anchor, confirmedDate: clockInDate)

                let vc = WorkTimePickerViewController(viewModel: vm)

                vm.confirmSelectedTime
                    .do(onNext: { [weak self] d in self?.clockInDate = d })
                    .map { DateFormatter.ko12hTimeFormatter.string(from: $0) }
                    .observe(on: MainScheduler.instance)
                    .take(until: vc.rx.deallocated)
                    .bind(to: workRegisterView.rx.selectedClockInTimeText)
                    .disposed(by: disposeBag)

                vm.confirmSelectedTime
                    .take(1)
                    .take(until: vc.rx.deallocated)
                    .bind(onNext: { [weak vc] _ in vc?.dismiss(animated: true) })
                    .disposed(by: disposeBag)

                vm.dismiss
                    .take(until: vc.rx.deallocated)
                    .bind(onNext: { [weak vc] in vc?.dismiss(animated: true) })
                    .disposed(by: disposeBag)

                present(vc, animated: true)
            })
            .disposed(by: disposeBag)

        // MARK: - 퇴근 시간
        workRegisterView.rx.clockOutTap
            .bind(onNext: { [weak self] in
                guard let self else { return }

                let vm = viewModel.clockOutVM
                let anchor = anchorDate(workDate: selectedWorkDate, time: clockOutDate)
                vm.reconfigure(anchorDate: anchor, confirmedDate: clockOutDate)

                let vc = WorkTimePickerViewController(viewModel: vm)

                vm.confirmSelectedTime
                    .do(onNext: { [weak self] d in self?.clockOutDate = d })
                    .map { DateFormatter.ko12hTimeFormatter.string(from: $0) }
                    .observe(on: MainScheduler.instance)
                    .take(until: vc.rx.deallocated)
                    .bind(to: workRegisterView.rx.selectedClockOutTimeText)
                    .disposed(by: disposeBag)

                vm.confirmSelectedTime
                    .take(1)
                    .take(until: vc.rx.deallocated)
                    .bind(onNext: { [weak vc] _ in vc?.dismiss(animated: true) })
                    .disposed(by: disposeBag)

                vm.dismiss
                    .take(until: vc.rx.deallocated)
                    .bind(onNext: { [weak vc] in vc?.dismiss(animated: true) })
                    .disposed(by: disposeBag)

                present(vc, animated: true)
            })
            .disposed(by: disposeBag)

        // MARK: - 휴게 시간
        workRegisterView.rx.lunchBreakTap
            .bind(onNext: { [weak self] in
                guard let self else { return }

                let vm = viewModel.breakPickerVM
                let vc = WorkBreakPickerViewController(viewModel: vm)

                vm.confirmSelectedBreak
                    .map { minutes -> String in
                        let hours = minutes / 60
                        let mins = minutes % 60
                        if hours > 0 && mins > 0 {
                            return "\(hours)시간 \(mins)분"
                        } else if hours > 0 {
                            return "\(hours)시간"
                        } else if mins > 0 {
                            return "\(mins)분"
                        } else {
                            return "없음"
                        }
                    }
                    .observe(on: MainScheduler.instance)
                    .take(until: vc.rx.deallocated)
                    .bind(to: workRegisterView.rx.selectedLunchBreakTimeText)
                    .disposed(by: disposeBag)

                vm.confirmSelectedBreak
                    .take(1)
                    .take(until: vc.rx.deallocated)
                    .bind(onNext: { [weak vc] _ in vc?.dismiss(animated: true) })
                    .disposed(by: disposeBag)

                vm.dismiss
                    .take(until: vc.rx.deallocated)
                    .bind(onNext: { [weak vc] in vc?.dismiss(animated: true) })
                    .disposed(by: disposeBag)

                present(vc, animated: true)
            })
            .disposed(by: disposeBag)

        // MARK: - 루틴
        workRegisterView.rx.routinTap
            .bind(onNext: { [weak self] in
                self?.coordinator?.showRoutineSelection()
            })
            .disposed(by: disposeBag)
        
        viewModel.selectedRoutines
            .observe(on: MainScheduler.instance)
            .bind(to: workRegisterView.rx.selectedRoutines)
            .disposed(by: disposeBag)

        // MARK: - 메모
        workRegisterView.getMemoContainerView.rx.text
            .bind(to: viewModel.memoText)
            .disposed(by: disposeBag)

        // MARK: - 등록 버튼
        viewModel.isFormValidForWorker
            .drive(with: self, onNext: { owner, isValid in
                owner.workRegisterView.getRegisterButton.isEnabled = isValid
            }).disposed(by: disposeBag)
        
        workRegisterView.getRegisterButton.rx.tap
            .bind(to: viewModel.didTapRegister)
            .disposed(by: disposeBag)

        viewModel.didCompleteRegister
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] in
                print("근무 등록 완료")
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.errorMessage.asDriver(onErrorJustReturn: (title: "오류 발생", message: "잠시 후 다시 시도해주세요."))
            .drive(with: self) { owner, errorMessage in
                owner.presentNoticeModal(title: errorMessage.title, comment: errorMessage.message)
            }.disposed(by: disposeBag)
    }
}

