//
//  MyWorkFormView.swift
//  MOUP
//
//  Created by 서동환 on 3/17/26.
//

import OSLog
import SwiftUI
import UIKit

struct MyWorkFormView: View {

    // MARK: - Nested Types

    /// 등록/수정 모드
    ///
    /// 수정 모드는 `workId`만 받고 화면 진입 후 상세를 조회한다.
    enum Mode {
        case create(selectedDate: Date)
        case edit(workId: Int)
    }

    // MARK: - Properties

    private let navigationController: UINavigationController?
    @State private var routineCoordinator: RoutineSelectionCoordinator?

    private let mode: Mode
    private let isEditing: Bool

    private let workUseCase: WorkUseCaseProtocol
    private let workplaceUseCase: WorkplaceUseCaseProtocol

    @State private var form: MyWorkForm

    @State private var workplaces: [WorkplaceSummary] = []
    @State private var showWorkplaceSelect = false
    @State private var showRepeatSettings = false

    @State private var isDatePickerPresented = false
    @State private var isStartTimePickerPresented = false
    @State private var isEndTimePickerPresented = false
    @State private var isBreakTimePickerPresented = false

    @State private var isSaving = false

    private var isEditMode: Bool {
        if case .edit = mode { return true }
        return false
    }

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "MyWorkFormView")

    // MARK: - Initializer

    init(navigationController: UINavigationController? = nil,
         mode: Mode,
         isEditing: Bool,
         workUseCase: WorkUseCaseProtocol,
         workplaceUseCase: WorkplaceUseCaseProtocol) {
        self.navigationController = navigationController
        self.mode = mode
        self.isEditing = isEditing
        self.workUseCase = workUseCase
        self.workplaceUseCase = workplaceUseCase

        switch mode {
        case .create(let selectedDate):
            self._form = State(initialValue: MyWorkForm(selectedDate: selectedDate))
        case .edit:
            self._form = State(initialValue: MyWorkForm())
        }
    }

    // MARK: - Content

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                WorkplaceButton(titleLabel: form.selectedWorkplace?.name ?? "근무지 선택",
                                isRequired: form.selectedWorkplace == nil) {
                    Task { await fetchWorkplaces() }
                }

                ContainerView(title: "근무 날짜", isRequired: true) {
                    PickerRow(title: "날짜", buttonTitle: form.formattedDate) {
                        isDatePickerPresented = true
                    }
                    LabelChevronRowView(titleLabel: "반복", rightLabel: form.formattedRepeatDays) {
                        showRepeatSettings = true
                    }
                }

                ContainerView(title: "근무시간", isRequired: true) {
                    PickerRow(title: "출근", buttonTitle: form.formattedStartTime) {
                        isStartTimePickerPresented = true
                    }
                    PickerRow(title: "퇴근", buttonTitle: form.formattedEndTime) {
                        isEndTimePickerPresented = true
                    }
                    PickerRow(title: "휴게", buttonTitle: form.formattedBreakTime) {
                        isBreakTimePickerPresented = true
                    }
                }

                ContainerView(title: "루틴") {
                    LabelChevronRowView(titleLabel: "루틴 추가", rightLabel: form.formattedRoutineCount) {
                        showRoutineSelection()
                    }
                }

                ContainerView(title: "메모") {
                    MemoView(text: $form.memo)
                }
            }
            .disabled(!isEditing)

            Spacer()
                .frame(height: 60)

            if isEditing {
                BaseButtonSU(title: isEditMode ? "수정하기" : "등록하기") {
                    Task { await handleRegister() }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .disabled(!form.isValid || isSaving)

                Spacer()
                    .frame(height: UIApplication.safeAreaBottom + 12)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .ignoresSafeArea(edges: .bottom)
        .task {
            await loadWorkDetailIfNeeded()
        }
        .navigationDestination(isPresented: $showWorkplaceSelect) {
            WorkplaceSelectView(
                workplaces: workplaces,
                selectedWorkplace: $form.selectedWorkplace
            )
        }
        .navigationDestination(isPresented: $showRepeatSettings) {
            WorkRepeatSettingsView(
                repeatDays: $form.repeatDays,
                repeatEndDate: $form.repeatEndDate
            )
        }
        .sheet(isPresented: $isDatePickerPresented) {
            DatePickerModal(selectedDate: $form.selectedDate, isPresented: $isDatePickerPresented)
        }
        .sheet(isPresented: $isStartTimePickerPresented) {
            TimePickerModal(selectedTime: $form.selectedStartTime, isPresented: $isStartTimePickerPresented)
        }
        .sheet(isPresented: $isEndTimePickerPresented) {
            TimePickerModal(selectedTime: $form.selectedEndTime, isPresented: $isEndTimePickerPresented)
        }
        .sheet(isPresented: $isBreakTimePickerPresented) {
            BreakTimePickerModal(selectedMinutes: $form.selectedBreakTime, isPresented: $isBreakTimePickerPresented)
        }
        .background(.primaryBackground)
    }
}

// MARK: - Private Methods

private extension MyWorkFormView {

    /// 앱 전체와 동일한 알림 모달을 표시한다.
    ///
    /// SwiftUI의 `.fullScreenCover`로 띄우면 배경이 불투명해져 폼 위에 겹쳐 보이지 않으므로,
    /// 주입받은 `UINavigationController`에 UIKit 방식으로 present 한다.
    func presentNotice(title: String, comment: String) {
        navigationController?.presentNoticeModal(title: title, comment: comment)
    }

    /// 수정 모드일 때 근무 상세를 조회해 폼을 채운다.
    func loadWorkDetailIfNeeded() async {
        guard case .edit(let workId) = mode else { return }

        do {
            form = MyWorkForm(workData: try await workUseCase.fetchMyWorkDetail(workId: workId))
        } catch {
            logger.error("근무 상세 조회 실패: \(error.localizedDescription)")
            presentNotice(title: "데이터 불러오기 실패",
                          comment: "근무 정보를 불러오지 못했습니다.\n다시 시도해주세요.")
        }
    }

    /// 근무지 목록을 조회한 뒤 선택 화면으로 이동한다.
    func fetchWorkplaces() async {
        do {
            workplaces = try await workplaceUseCase.fetchAllWorkplace()
            showWorkplaceSelect = true
        } catch {
            logger.error("근무지 목록 조회 실패: \(error.localizedDescription)")
            presentNotice(title: "데이터 불러오기 실패",
                          comment: "근무지 목록을 불러오지 못했습니다.\n다시 시도해주세요.")
        }
    }

    func showRoutineSelection() {
        guard let nav = navigationController else { return }

        let coordinator = RoutineSelectionCoordinator(navigationController: nav)
        coordinator.onRoutinesSelected = { routines in
            form.routines = routines
        }
        coordinator.start()

        routineCoordinator = coordinator
    }

    /// 근무를 등록하거나 수정한다. 성공 시 이전 화면으로 돌아간다.
    func handleRegister() async {
        guard let workplace = form.selectedWorkplace else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            switch mode {
            case .create:
                _ = try await workUseCase.createMyWork(workplaceId: workplace.id,
                                                       requestDTO: form.createRequestDTO)
            case .edit(let workId):
                try await workUseCase.updateMySingleWork(workId: workId,
                                                         requestDTO: form.updateRequestDTO)
            }
            navigationController?.popViewController(animated: true)
        } catch {
            logger.error("근무 저장 실패: \(error.localizedDescription)")
            presentNotice(title: "근무 저장 실패",
                          comment: "근무 저장 중 오류가 발생했습니다.\n다시 시도해주세요.")
        }
    }
}

// MARK: - Preview

#Preview {
    MyWorkFormView(
        mode: .create(selectedDate: Date()),
        isEditing: true,
        workUseCase: WorkUseCase(workRepository: WorkRepository(workService: WorkService())),
        workplaceUseCase: WorkplaceUseCase(workplaceRepository: WorkplaceRepository(workplaceService: WorkplaceService()))
    )
}
