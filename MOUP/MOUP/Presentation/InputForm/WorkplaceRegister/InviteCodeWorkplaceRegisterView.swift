//
//  InviteCodeWorkplaceRegisterView.swift
//  MOUP
//
//  Created by 서동환 on 8/27/26.
//

import OSLog
import SwiftUI
import UIKit

/// 초대코드로 근무지에 참여하는 화면
///
/// 등록 전용이라 수정 모드가 없다. 근무지 이름·카테고리는 초대코드가 결정하므로
/// 입력받지 않고 네비바 타이틀로만 보여준다. 급여·근무조건·색상라벨만 입력받는다.
/// `UIHostingController`로 감싸 UIKit 네비게이션 스택에 push 해서 사용한다.
/// `navigationController`는 Coordinator에서 주입받아 하위 화면 전환과 pop에 사용한다.
struct InviteCodeWorkplaceRegisterView: View {

    // MARK: - Properties

    private let navigationController: UINavigationController?
    private let workplaceName: String
    private let inviteCode: String
    private let workplaceUseCase: WorkplaceUseCaseProtocol
    private let onJoined: (() -> Void)?

    @State private var form = WorkplaceForm()
    @State private var isSaving = false

    @State private var showPayTypeSelect = false
    @State private var showPayCalculationSelect = false
    @State private var showSalaryInput = false
    @State private var showColorLabelSelect = false
    @State private var isPayDayPickerPresented = false

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "InviteCodeWorkplaceRegisterView")

    /// push된 하위 위저드가 하나라도 떠 있는지 여부.
    ///
    /// `isPayDayPickerPresented`는 `.sheet`라 넣지 않는다 — 시트는 화면을 덮어
    /// 가장자리 스와이프 자체가 들어오지 않으므로 이 판단과 무관하다.
    private var isWizardPresented: Bool {
        showPayTypeSelect || showPayCalculationSelect || showSalaryInput || showColorLabelSelect
    }

    // MARK: - Initializer

    init(navigationController: UINavigationController? = nil,
         workplaceName: String,
         inviteCode: String,
         workplaceUseCase: WorkplaceUseCaseProtocol,
         onJoined: (() -> Void)? = nil) {
        self.navigationController = navigationController
        self.workplaceName = workplaceName
        self.inviteCode = inviteCode
        self.workplaceUseCase = workplaceUseCase
        self.onJoined = onJoined
    }

    // MARK: - Content

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                BaseNavigationBarSU(
                    title: workplaceName.isEmpty ? "초대코드 근무지 등록" : workplaceName,
                    onBackTap: { navigationController?.popViewController(animated: true) }
                )

                ScrollView {
                    VStack(spacing: 24) {
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

                    BaseButtonSU(title: "등록하기") {
                        Task { await join() }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .disabled(!form.isJoinValid || isSaving)

                    Spacer().frame(height: UIApplication.safeAreaBottom + 12)
                }
                .scrollDismissesKeyboard(.interactively)
                .ignoresSafeArea(edges: .bottom)
            }
            .toolbar(.hidden, for: .navigationBar)
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
            // 하위 위저드가 떠 있는 동안은 canPop을 false로 막아, 스와이프가 위저드를
            // 건너뛰고 바깥(홈)까지 나가버리는 것을 막는다.
            NavigationControllerFinder(canPop: !isWizardPresented) { _ in }
                .frame(width: 0, height: 0)
        )
    }
}

// MARK: - Private Methods

/// `View.body`만 `@MainActor`라, 여기 있는 async 메서드는 그대로 두면 메인 스레드 밖에서
/// `@State`와 UIKit을 건드린다. 확산되지 않도록 extension 전체를 메인 액터에 묶는다.
@MainActor private extension InviteCodeWorkplaceRegisterView {

    func presentNotice(title: String, comment: String, onConfirm: (() -> Void)? = nil) {
        navigationController?.presentNoticeModal(title: title, comment: comment, onConfirm: onConfirm)
    }

    func join() async {
        guard form.isJoinValid, !isSaving else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            _ = try await workplaceUseCase.joinWorkplace(request: form.joinRequestDTO(inviteCode: inviteCode))
            // 복귀는 Coordinator가 한다. 기존 UIKit도 pop이 아니라 홈 스택을 다시 세운다.
            onJoined?()
        } catch {
            logger.error("근무지 참여 실패: \(error.localizedDescription)")
            presentNotice(title: "참여 실패", comment: "근무지 참여에 실패했습니다.\n다시 시도해주세요.")
        }
    }
}
