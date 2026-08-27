//
//  OwnerWorkRegisterView.swift
//  MOUP
//
//  Created by 서동환 on 8/16/26.
//

import SwiftUI

/// 사장님 근무 등록/수정 화면
///
/// `UIHostingController`로 감싸 UIKit 네비게이션 스택에 push 해서 사용한다.
/// `navigationController`는 Coordinator에서 주입받아 하위 화면 전환과 pop에 사용한다.
struct OwnerWorkRegisterView: View {

    typealias Mode = WorkerWorkFormView.Mode

    // MARK: - Properties

    private let navigationController: UINavigationController?
    private let mode: Mode

    private let workUseCase: WorkUseCaseProtocol
    private let workplaceUseCase: WorkplaceUseCaseProtocol
    private let attendanceUseCase: AttendanceUseCaseProtocol

    /// 저장에 성공했을 때 저장된 근무 날짜를 알린다.
    private let onSaved: ((Date) -> Void)?

    @State private var isEditing: Bool
    @State private var hasChanges = false
    /// `WorkerWorkFormView`가 알려주는, push된 하위 위저드 표시 여부.
    @State private var isWizardPresented = false

    private var navigationTitle: String {
        guard isEditMode else { return "근무 등록" }
        return isEditing ? "근무 수정" : "근무 상세"
    }

    /// 수정 모드 여부
    private var isEditMode: Bool {
        if case .edit = mode { return true }
        return false
    }

    // MARK: - Initializer

    init(navigationController: UINavigationController? = nil,
         mode: Mode,
         workUseCase: WorkUseCaseProtocol,
         workplaceUseCase: WorkplaceUseCaseProtocol,
         attendanceUseCase: AttendanceUseCaseProtocol,
         onSaved: ((Date) -> Void)? = nil) {
        self.navigationController = navigationController
        self.mode = mode
        self.workUseCase = workUseCase
        self.workplaceUseCase = workplaceUseCase
        self.attendanceUseCase = attendanceUseCase
        self.onSaved = onSaved

        switch mode {
        case .create:
            self._isEditing = State(initialValue: true)   // 등록 모드: 항상 활성화
        case .edit:
            self._isEditing = State(initialValue: false)  // 수정 모드: 잠금 상태로 시작
        }
    }

    // MARK: - Content

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                BaseNavigationBarSU(
                    title: navigationTitle,
                    rightTitle: isEditMode && !isEditing ? "수정" : nil,
                    onBackTap: {
                        // 수정 중이면 화면을 벗어나지 않고 상세로 돌아간다.
                        guard isEditMode, isEditing else {
                            navigationController?.popViewController(animated: true)
                            return
                        }

                        // 수정한 내용이 있을 때만 취소 여부를 묻는다.
                        guard hasChanges else {
                            isEditing = false
                            return
                        }

                        navigationController?.presentNoticeModal(
                            title: "수정을 취소할까요?",
                            comment: "수정한 내용은 저장되지 않습니다.",
                            cancelTitle: "계속 수정",
                            confirmTitle: "취소하기",
                            // 잠금으로 되돌리면 `WorkerWorkFormView`가 조회 시점 값으로 폼을 복원한다.
                            onConfirm: { isEditing = false }
                        )
                    },
                    onRightTap: {
                        isEditing = true
                    }
                )

                WorkerWorkFormView(
                    navigationController: navigationController,
                    mode: mode,
                    isEditing: $isEditing,
                    hasChanges: $hasChanges,
                    isWizardPresented: $isWizardPresented,
                    workUseCase: workUseCase,
                    workplaceUseCase: workplaceUseCase,
                    attendanceUseCase: attendanceUseCase,
                    onSaved: onSaved
                )
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .background(
            // 상위 UIKit 네비게이션의 스와이프 백 제스처를 복원하기 위해 유지한다.
            // 하위 위저드(근무지/근무자 선택 등)가 떠 있는 동안은 canPop을 false로 막아, 스와이프가
            // 위저드를 건너뛰고 바깥(캘린더)까지 나가버리는 것을 막는다.
            NavigationControllerFinder(canPop: !isWizardPresented) { _ in }
                .frame(width: 0, height: 0)
        )
    }
}

// MARK: - Preview

#Preview {
    OwnerWorkRegisterView(
        mode: .create(selectedDate: Date()),
        workUseCase: WorkUseCase(workRepository: WorkRepository(workService: WorkService())),
        workplaceUseCase: WorkplaceUseCase(workplaceRepository: WorkplaceRepository(workplaceService: WorkplaceService())),
        attendanceUseCase: AttendanceUseCase(attendanceRepository: AttendanceRepository(attendanceService: AttendanceService()))
    )
}
