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
    @Binding private var isEditing: Bool
    /// 폼이 조회 시점과 달라졌는지 여부. 뒤로가기 시 확인 모달을 띄울지 판단하는 데 쓴다.
    @Binding private var hasChanges: Bool

    /// 수정 모드 진입 직전의 폼. 수정을 취소하면 이 값으로 되돌린다.
    @State private var originalForm: MyWorkForm?

    private let workUseCase: WorkUseCaseProtocol
    private let workplaceUseCase: WorkplaceUseCaseProtocol

    /// 저장에 성공했을 때 저장된 근무 날짜를 알린다.
    private let onSaved: ((Date) -> Void)?

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

    /// 잠금 상태에서 루틴이 없으면 "추가"를 유도하지 않는다.
    private var routineRowTitle: String {
        !isEditing && form.routines.isEmpty ? "루틴이 없습니다" : "루틴 추가"
    }

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "MyWorkFormView")

    // MARK: - Initializer

    init(navigationController: UINavigationController? = nil,
         mode: Mode,
         isEditing: Binding<Bool>,
         hasChanges: Binding<Bool> = .constant(false),
         workUseCase: WorkUseCaseProtocol,
         workplaceUseCase: WorkplaceUseCaseProtocol,
         onSaved: ((Date) -> Void)? = nil) {
        self.navigationController = navigationController
        self.mode = mode
        self._isEditing = isEditing
        self._hasChanges = hasChanges
        self.workUseCase = workUseCase
        self.workplaceUseCase = workplaceUseCase
        self.onSaved = onSaved

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
                    LabelChevronRowView(titleLabel: routineRowTitle, rightLabel: form.formattedRoutineCount) {
                        showRoutineSelection()
                    }
                }

                ContainerView(title: "메모") {
                    MemoView(text: $form.memo)
                }
            }
            .disabled(!isEditing)
            .padding(.top, 20)

            Spacer()
                .frame(height: 60)

            if isEditing {
                BaseButtonSU(title: isEditMode ? "수정하기" : "등록하기") {
                    handleSaveTap()
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
        .onChange(of: form) { form in // Deprecated 예정, iOS 17부터 onChange(of:initial:_:)로 변경
            hasChanges = originalForm != nil && form != originalForm
        }
        .onChange(of: isEditing) { isEditing in // Deprecated 예정, iOS 17부터 onChange(of:initial:_:)로 변경
            // 수정이 취소되면(잠금 복귀) 조회 시점의 값으로 되돌린다.
            guard !isEditing, let originalForm else { return }
            form = originalForm
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

/// `View.body`만 `@MainActor`라, 여기 있는 async 메서드는 그대로 두면 메인 스레드 밖에서
/// `@State`와 UIKit을 건드린다. 확산되지 않도록 extension 전체를 메인 액터에 묶는다.
@MainActor private extension MyWorkFormView {

    /// 앱 전체와 동일한 알림 모달을 표시한다.
    ///
    /// SwiftUI의 `.fullScreenCover`로 띄우면 배경이 불투명해져 폼 위에 겹쳐 보이지 않으므로,
    /// 주입받은 `UINavigationController`에 UIKit 방식으로 present 한다.
    func presentNotice(title: String, comment: String) {
        navigationController?.presentNoticeModal(title: title, comment: comment)
    }

    /// 수정 모드일 때 근무 상세를 조회해 폼을 채운다.
    ///
    /// `.task`는 하위 화면에서 복귀할 때도 다시 실행되므로, 이미 조회했으면 건너뛴다.
    /// 그렇지 않으면 반복 설정·근무지 선택 결과가 서버 값으로 덮어써진다.
    func loadWorkDetailIfNeeded() async {
        guard case .edit(let workId) = mode, originalForm == nil else { return }

        do {
            form = MyWorkForm(workData: try await workUseCase.fetchMyWorkDetail(workId: workId))
            originalForm = form
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

    /// 저장 버튼을 눌렀을 때의 진입점
    ///
    /// 반복 근무를 수정하는 경우에는 적용 범위를 먼저 묻는다.
    func handleSaveTap() {
        guard isEditMode, originalForm?.hasRepeat == true else {
            Task { await save(appliesToRecurring: false) }
            return
        }

        navigationController?.presentNoticeModal(
            title: "반복 근무 수정",
            comment: "수정 범위를 선택해주세요.",
            cancelTitle: "취소",
            confirmTitle: "이 근무만 수정",
            otherTitle: "이후 모든 근무 수정",
            onConfirm: { Task { await save(appliesToRecurring: false) } },
            onOther: { Task { await save(appliesToRecurring: true) } }
        )
    }

    /// 근무를 등록하거나 수정한다. 성공 시 이전 화면으로 돌아간다.
    /// - Parameter appliesToRecurring: 반복 근무 전체에 적용할지 여부
    func save(appliesToRecurring: Bool) async {
        guard let workplace = form.selectedWorkplace else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            switch mode {
            case .create:
                _ = try await workUseCase.createMyWork(workplaceId: workplace.id,
                                                       requestDTO: form.createRequestDTO)
            case .edit(let workId) where appliesToRecurring:
                _ = try await workUseCase.updateMyRecurringWork(workId: workId,
                                                                requestDTO: form.updateRequestDTO)
            case .edit(let workId):
                try await workUseCase.updateMySingleWork(workId: workId,
                                                         requestDTO: form.updateRequestDTO)
            }
            onSaved?(form.selectedDate)
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
        isEditing: .constant(true),
        workUseCase: WorkUseCase(workRepository: WorkRepository(workService: WorkService())),
        workplaceUseCase: WorkplaceUseCase(workplaceRepository: WorkplaceRepository(workplaceService: WorkplaceService()))
    )
}
