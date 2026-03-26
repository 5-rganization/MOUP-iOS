//
//  MyWorkFormView.swift
//  MOUP
//
//  Created by 서동환 on 3/17/26.
//

import SwiftUI
import UIKit

struct MyWorkFormView: View {
    
    // MARK: - Properties
    
    private let navigationController: UINavigationController?
    @State private var routineCoordinator: RoutineSelectionCoordinator?
    
    @State private var form: MyWorkForm
    private let isEditing: Bool
    
    @State private var workplaces: [WorkplaceSummary] = []
    @State private var showWorkplaceSelect = false
    @State private var showRepeatSettings = false
    
    @State private var isDatePickerPresented = false
    @State private var isStartTimePickerPresented = false
    @State private var isEndTimePickerPresented = false
    @State private var isBreakTimePickerPresented = false
    
    // MARK: - Initializer
    
    init(navigationController: UINavigationController? = nil, selectedDate: Date = Date(), isEditing: Bool = true) {
        self.navigationController = navigationController
        self._form = State(initialValue: MyWorkForm(selectedDate: selectedDate))
        self.isEditing = isEditing
    }
    
    init(navigationController: UINavigationController? = nil, workData: MyWorkData, isEditing: Bool) {
        self.navigationController = navigationController
        self._form = State(initialValue: MyWorkForm(workData: workData))
        self.isEditing = isEditing
    }
    
    // MARK: - Content
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                WorkplaceButton(titleLabel: form.selectedWorkplace?.name ?? "근무지 선택",
                                isRequired: form.selectedWorkplace == nil) {
                    fetchWorkplaces()
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
                BaseButtonSU(title: "등록하기") {
                    handleRegister()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .disabled(!form.isValid)
                
                Spacer()
                    .frame(height: UIApplication.safeAreaBottom + 12)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .ignoresSafeArea(edges: .bottom)
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
    func fetchWorkplaces() {
        // TODO: API 호출
        // 성공 시:
        // workplaces = 응답 데이터
        showWorkplaceSelect = true
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
    
    func handleRegister() {
        // TODO: form → API 요청 DTO 변환 후 등록
    }
}

// MARK: - Preview

#Preview {
    MyWorkFormView()
}
