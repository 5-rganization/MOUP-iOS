//
//  WorkerWorkRegisterView.swift
//  MOUP
//
//  Created by 서동환 on 3/26/26.
//

import SwiftUI

struct WorkerWorkRegisterView: View {
    
    // MARK: - Properties
    
    @State private var navigationController: UINavigationController?
    @State private var isEditing: Bool
    
    private let selectedDate: Date
    private let workData: MyWorkData?
    
    /// 수정 모드 여부 (workData가 있으면 수정 모드)
    private var isEditMode: Bool { workData != nil }
    
    // MARK: - Initializer
    
    init(selectedDate: Date = Date()) {
        self.selectedDate = selectedDate
        self.workData = nil
        self._isEditing = State(initialValue: true) // 등록 모드: 항상 활성화
    }
    
    init(workData: MyWorkData) {
        self.selectedDate = Date()
        self.workData = workData
        self._isEditing = State(initialValue: false) // 수정 모드: 잠금 상태로 시작
    }
    
    // MARK: - Content
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                BaseNavigationBarSU(
                    title: isEditMode ? "근무 수정" : "근무 등록",
                    rightTitle: isEditMode && !isEditing ? "수정하기" : nil,
                    onBackTap: {
                        navigationController?.popViewController(animated: true)
                    },
                    onRightTap: {
                        isEditing = true
                    }
                )
                
                Group {
                    if let workData {
                        MyWorkFormView(
                            navigationController: navigationController,
                            workData: workData,
                            isEditing: isEditing
                        )
                    } else {
                        MyWorkFormView(
                            navigationController: navigationController,
                            selectedDate: selectedDate
                        )
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .background(
            NavigationControllerFinder { nav in
                navigationController = nav
            }
                .frame(width: 0, height: 0)
        )
    }
}

// MARK: - Preview

#Preview {
    WorkerWorkRegisterView()
}
