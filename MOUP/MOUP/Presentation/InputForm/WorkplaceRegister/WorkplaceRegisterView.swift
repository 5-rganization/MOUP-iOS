//
//  WorkplaceRegisterView.swift
//  MOUP
//
//  Created by 서동환 on 8/27/26.
//

import OSLog
import SwiftUI
import UIKit

/// 알바생 직접 근무지 등록/수정 화면
///
/// `UIHostingController`로 감싸 UIKit 네비게이션 스택에 push 해서 사용한다.
/// `navigationController`는 Coordinator에서 주입받아 하위 화면 전환과 pop에 사용한다.
struct WorkplaceRegisterView: View {

    enum Mode {
        case create
        case edit(workplaceId: Int)
    }

    // MARK: - Properties

    private let navigationController: UINavigationController?
    private let mode: Mode
    private let workplaceUseCase: WorkplaceUseCaseProtocol
    private let onSaved: ((Int) -> Void)?

    @State private var form = WorkplaceForm()
    @State private var isLoaded = false
    @State private var isSaving = false

    @State private var showNameInput = false
    @State private var showCategorySelect = false
    @State private var showPayTypeSelect = false
    @State private var showPayCalculationSelect = false
    @State private var showSalaryInput = false
    @State private var showColorLabelSelect = false
    @State private var isPayDayPickerPresented = false

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "WorkplaceRegisterView")

    private var isEditMode: Bool {
        if case .edit = mode { return true }
        return false
    }

    // MARK: - Initializer

    init(navigationController: UINavigationController? = nil,
         mode: Mode,
         workplaceUseCase: WorkplaceUseCaseProtocol,
         onSaved: ((Int) -> Void)? = nil) {
        self.navigationController = navigationController
        self.mode = mode
        self.workplaceUseCase = workplaceUseCase
        self.onSaved = onSaved
    }

    // MARK: - Content

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                BaseNavigationBarSU(
                    title: isEditMode ? "근무지 수정" : "새 근무지 등록",
                    onBackTap: { navigationController?.popViewController(animated: true) }
                )

                ScrollView {
                    VStack(spacing: 24) {
                        WorkplaceSection(form: $form,
                                         onNameTap: { showNameInput = true },
                                         onCategoryTap: { showCategorySelect = true })
                        PaySection(form: $form,
                                   onPayTypeTap: { showPayTypeSelect = true },
                                   onPayCalculationTap: { showPayCalculationSelect = true },
                                   onSalaryTap: { showSalaryInput = true },
                                   onPayDayTap: { isPayDayPickerPresented = true })
                        WorkingConditionsSection(form: $form)
                        ColorLabelSection(form: $form, onTap: { showColorLabelSelect = true })
                    }
                    .padding(.top, 20)

                    Spacer().frame(height: 60)

                    BaseButtonSU(title: isEditMode ? "수정하기" : "등록하기") {
                        Task { await save() }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .disabled(!form.isWorkerValid || isSaving)

                    Spacer().frame(height: UIApplication.safeAreaBottom + 12)
                }
                .scrollDismissesKeyboard(.interactively)
                .ignoresSafeArea(edges: .bottom)
            }
            .toolbar(.hidden, for: .navigationBar)
            .task { await loadDetailIfNeeded() }
            .navigationDestination(isPresented: $showNameInput) {
                NameInputView(workplaceName: $form.workplaceName)
            }
            .navigationDestination(isPresented: $showCategorySelect) {
                CategorySelectView(category: $form.category)
            }
            .navigationDestination(isPresented: $showPayTypeSelect) {
                PayTypeSelectView(salaryType: $form.salaryType)
            }
            .navigationDestination(isPresented: $showPayCalculationSelect) {
                PayCalculationSelectView(salaryCalculation: $form.salaryCalculation)
            }
            .navigationDestination(isPresented: $showSalaryInput) {
                SalaryInputView(salaryAmount: $form.salaryAmount,
                                salaryCalculation: form.salaryCalculation)
            }
            .navigationDestination(isPresented: $showColorLabelSelect) {
                ColorLabelSelectView(labelColor: $form.labelColor)
            }
            .sheet(isPresented: $isPayDayPickerPresented) {
                PayDayPickerSheet(payDay: $form.payDay, isPresented: $isPayDayPickerPresented)
            }
            .background(.primaryBackground)
        }
        .background(
            // 상위 UIKit 네비게이션의 스와이프 백 제스처를 복원하기 위해 유지한다.
            NavigationControllerFinder { _ in }
                .frame(width: 0, height: 0)
        )
    }
}

// MARK: - Private Methods

/// `View.body`만 `@MainActor`라, 여기 있는 async 메서드는 그대로 두면 메인 스레드 밖에서
/// `@State`와 UIKit을 건드린다. 확산되지 않도록 extension 전체를 메인 액터에 묶는다.
@MainActor private extension WorkplaceRegisterView {

    func presentNotice(title: String, comment: String, onConfirm: (() -> Void)? = nil) {
        navigationController?.presentNoticeModal(title: title, comment: comment, onConfirm: onConfirm)
    }

    /// `.task`는 하위 화면에서 복귀할 때도 다시 실행되므로, 이미 조회했으면 건너뛴다.
    /// 그렇지 않으면 위저드에서 고른 값이 서버 값으로 덮어써진다.
    func loadDetailIfNeeded() async {
        guard case .edit(let workplaceId) = mode, !isLoaded else { return }

        do {
            form = WorkplaceForm(detail: try await workplaceUseCase.fetchWorkplaceDetail(workplaceId: workplaceId))
            isLoaded = true
        } catch {
            logger.error("근무지 상세 조회 실패: \(error.localizedDescription)")
            presentNotice(title: "데이터 불러오기 실패",
                          comment: "근무지 정보를 불러오지 못했습니다.\n다시 시도해주세요.",
                          onConfirm: { navigationController?.popViewController(animated: true) })
        }
    }

    func save() async {
        guard form.isWorkerValid, !isSaving else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            switch mode {
            case .create:
                let result = try await workplaceUseCase.createWorkplace(request: form.createRequestDTO)
                onSaved?(result.workplaceId)
            case .edit(let workplaceId):
                try await workplaceUseCase.updateWorkplace(workplaceId: workplaceId,
                                                           request: form.workerUpdateRequestDTO)
                onSaved?(workplaceId)
            }
            navigationController?.popViewController(animated: true)
        } catch {
            logger.error("근무지 저장 실패: \(error.localizedDescription)")
            presentNotice(title: "저장 실패", comment: "근무지를 저장하지 못했습니다.\n다시 시도해주세요.")
        }
    }
}
