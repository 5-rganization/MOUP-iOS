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
    
    @State private var isDatePickerPresented = false
    @State private var isStartTimePickerPresented = false
    @State private var isEndTimePickerPresented = false
    @State private var isBreakTimePickerPresented = false
    @State private var showRepeatSettings = false
    
    // MARK: - Initializer
    
    init(selectedDate: Date = Date(), navigationController: UINavigationController? = nil) {
        self._form = State(initialValue: MyWorkForm(selectedDate: selectedDate))
        self.navigationController = navigationController
    }
    
    init(from data: MyWorkData, navigationController: UINavigationController? = nil) {
        self._form = State(initialValue: MyWorkForm(from: data))
        self.navigationController = navigationController
    }
    
    // MARK: - Content
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                WorkplaceButton(titleLabel: form.selectedWorkplace?.name ?? "근무지 선택",
                                isRequired: form.selectedWorkplace == nil)
                
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
                
                BaseButtonSU(title: "등록하기") {
                    handleRegister()
                }
                .frame(height: 48)
                .padding(.horizontal, 16)
                .disabled(!form.isValid)
            }
            .padding(.bottom, 16)
        }
        .scrollDismissesKeyboard(.interactively)
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
