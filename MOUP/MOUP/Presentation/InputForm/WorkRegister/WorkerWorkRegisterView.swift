//
//  WorkerWorkRegisterView.swift
//  MOUP
//
//  Created by 서동환 on 3/26/26.
//

import SwiftUI

/// 알바생 근무 등록/수정 화면
///
/// `UIHostingController`로 감싸 UIKit 네비게이션 스택에 push 해서 사용한다.
/// `navigationController`는 Coordinator에서 주입받아 하위 화면 전환과 pop에 사용한다.
struct WorkerWorkRegisterView: View {

    typealias Mode = MyWorkFormView.Mode

    // MARK: - Properties

    private let navigationController: UINavigationController?
    private let mode: Mode

    private let workUseCase: WorkUseCaseProtocol
    private let workplaceUseCase: WorkplaceUseCaseProtocol

    /// 저장에 성공했을 때 저장된 근무 날짜를 알린다.
    private let onSaved: ((Date) -> Void)?

    @State private var isEditing: Bool

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
         onSaved: ((Date) -> Void)? = nil) {
        self.navigationController = navigationController
        self.mode = mode
        self.workUseCase = workUseCase
        self.workplaceUseCase = workplaceUseCase
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
                    title: isEditMode ? "근무 수정" : "근무 등록",
                    rightTitle: isEditMode && !isEditing ? "수정" : nil,
                    onBackTap: {
                        // 수정 중이면 바로 나가지 않고 취소 여부를 먼저 묻는다.
                        guard isEditMode, isEditing else {
                            navigationController?.popViewController(animated: true)
                            return
                        }

                        navigationController?.presentNoticeModal(
                            title: "수정을 취소할까요?",
                            comment: "수정한 내용은 저장되지 않습니다.",
                            cancelTitle: "계속 수정",
                            confirmTitle: "취소하기",
                            // 잠금으로 되돌리면 `MyWorkFormView`가 조회 시점 값으로 폼을 복원한다.
                            onConfirm: { isEditing = false }
                        )
                    },
                    onRightTap: {
                        isEditing = true
                    }
                )

                MyWorkFormView(
                    navigationController: navigationController,
                    mode: mode,
                    isEditing: $isEditing,
                    workUseCase: workUseCase,
                    workplaceUseCase: workplaceUseCase,
                    onSaved: onSaved
                )
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .background(
            // 상위 UIKit 네비게이션의 스와이프 백 제스처를 복원하기 위해 유지한다.
            NavigationControllerFinder { _ in }
                .frame(width: 0, height: 0)
        )
    }
}

// MARK: - Preview

#Preview {
    WorkerWorkRegisterView(
        mode: .create(selectedDate: Date()),
        workUseCase: WorkUseCase(workRepository: WorkRepository(workService: WorkService())),
        workplaceUseCase: WorkplaceUseCase(workplaceRepository: WorkplaceRepository(workplaceService: WorkplaceService()))
    )
}
