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
         workplaceUseCase: WorkplaceUseCaseProtocol) {
        self.navigationController = navigationController
        self.mode = mode
        self.workUseCase = workUseCase
        self.workplaceUseCase = workplaceUseCase

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
                        navigationController?.popViewController(animated: true)
                    },
                    onRightTap: {
                        isEditing = true
                    }
                )

                MyWorkFormView(
                    navigationController: navigationController,
                    mode: mode,
                    isEditing: isEditing,
                    workUseCase: workUseCase,
                    workplaceUseCase: workplaceUseCase
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
